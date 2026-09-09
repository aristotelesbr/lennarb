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
  end
end
