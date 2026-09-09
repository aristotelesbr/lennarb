require "test_helper"

module Lennarb
  class RequestHandlerTest < Minitest::Test
    def rack_env(path, method: "GET")
      {
        "REQUEST_METHOD" => method,
        "PATH_INFO" => path,
        "QUERY_STRING" => "",
        "SERVER_NAME" => "example.org",
        "SERVER_PORT" => "80",
        "rack.url_scheme" => "http",
        "rack.input" => StringIO.new
      }
    end

    test "returns 500 instead of leaking a StandardError outside development" do
      app_class = Class.new(Lennarb::App) do
        get("/boom") { |req, res| raise "kaboom" }
      end
      app = app_class.new
      app.env = :production
      app.initialize!

      status, headers, body = Lennarb::RequestHandler.new(app).call(rack_env("/boom"))

      assert_equal 500, status
      assert_equal "text/plain", headers["content-type"]
      assert_equal ["Internal Server Error"], body
    end

    test "re-raises in development so Rack::ShowExceptions can render it" do
      app_class = Class.new(Lennarb::App) do
        get("/boom") { |req, res| raise "kaboom" }
      end
      app = app_class.new
      app.env = :development
      app.initialize!

      error = assert_raises(RuntimeError) do
        Lennarb::RequestHandler.new(app).call(rack_env("/boom"))
      end

      assert_equal "kaboom", error.message
    end

    test "still serves a route that does not raise" do
      app_class = Class.new(Lennarb::App) do
        get("/ok") { |req, res| res.text("ok") }
      end
      app = app_class.new
      app.initialize!

      status, _, body = Lennarb::RequestHandler.new(app).call(rack_env("/ok"))

      assert_equal 200, status
      assert_equal ["ok"], body
    end

    test "reuses one context class instead of building a singleton per request" do
      app_class = Class.new(Lennarb::App) do
        get("/ok") { |req, res| res.text("ok") }
      end
      app = app_class.new
      app.initialize!
      handler = Lennarb::RequestHandler.new(app)

      first = handler.send(:create_context)
      second = handler.send(:create_context)

      refute_same first, second, "each request must get its own context instance"
      assert_same first.class, second.class, "the context class must be compiled once"
    end

    test "context exposes app and the app class helpers" do
      app_class = Class.new(Lennarb::App) do
        get("/ok") { |req, res| res.text("ok") }
      end
      app_class.helpers do
        def shout = "HI"
      end
      app = app_class.new
      app.initialize!

      context = Lennarb::RequestHandler.new(app).send(:create_context)

      assert_same app, context.app
      assert_equal "HI", context.shout
    end

    test "helpers defined after the first request are still visible" do
      app_class = Class.new(Lennarb::App) do
        get("/ok") { |req, res| res.text("ok") }
      end
      app = app_class.new
      app.initialize!
      handler = Lennarb::RequestHandler.new(app)

      handler.send(:create_context) # compiles the context class

      app_class.helpers do
        def late = "late"
      end

      assert_equal "late", handler.send(:create_context).late
    end

    test "context instances do not share ivars across requests" do
      app_class = Class.new(Lennarb::App) do
        get("/ok") { |req, res| res.text("ok") }
      end
      app = app_class.new
      app.initialize!
      handler = Lennarb::RequestHandler.new(app)

      first = handler.send(:create_context)
      first.instance_variable_set(:@leak, "leaked")

      assert_nil handler.send(:create_context).instance_variable_get(:@leak)
    end

    test "a route handler can call app without blowing the stack" do
      app_class = Class.new(Lennarb::App) do
        get("/whoami") { |req, res| res.text(app.env.to_s) }
      end
      app = app_class.new
      app.env = :production
      app.initialize!

      status, _, body = Lennarb::RequestHandler.new(app).call(rack_env("/whoami"))

      assert_equal 200, status
      assert_equal ["production"], body
    end

    test "route params are URL-decoded" do
      app_class = Class.new(Lennarb::App) do
        get("/u/:name") { |req, res| res.text(req.params[:name]) }
      end
      app = app_class.new
      app.env = :production
      app.initialize!

      _, _, body = Lennarb::RequestHandler.new(app).call(rack_env("/u/John%20Doe"))

      assert_equal ["John Doe"], body
    end

    test "a percent-encoded slash does not split a route segment" do
      app_class = Class.new(Lennarb::App) do
        get("/f/:name") { |req, res| res.text(req.params[:name]) }
      end
      app = app_class.new
      app.env = :production
      app.initialize!

      _, _, body = Lennarb::RequestHandler.new(app).call(rack_env("/f/a%2Fb"))

      assert_equal ["a/b"], body
    end

  end
end
