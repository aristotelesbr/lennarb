require "test_helper"

class AppTest < Minitest::Test
  setup do
    @original_env = Lennarb::ENV_NAMES.to_h { [it, ENV[it]] }
    Lennarb::ENV_NAMES.each { ENV.delete(it) }
  end

  teardown do
    # These tests set LENNA_ENV/APP_ENV/RACK_ENV and the suite runs in random
    # order, so anything left behind leaks into whatever runs next.
    @original_env.each { |name, value| value.nil? ? ENV.delete(name) : ENV[name] = value }
  end

  test "uses LENNA_ENV as the env value" do
    ENV["LENNA_ENV"] = "production"

    assert Lennarb::App.new.env.production?
  end

  test "uses APP_ENV as the env value" do
    ENV["APP_ENV"] = "production"

    assert Lennarb::App.new.env.production?
  end

  test "uses RACK_ENV as the env value" do
    ENV["RACK_ENV"] = "production"

    assert Lennarb::App.new.env.production?
  end

  test "sets config" do
    app = Lennarb::App.new do
      config do
        optional :one, string, "one"
      end

      config do
        optional :two, string, "two"
      end
    end

    assert_equal "one", app.config.one
    assert_equal "two", app.config.two
  end

  test "sets default middleware stack" do
    ENV["LENNA_ENV"] = "development"
    app = Lennarb::App.new
    stack = app.middleware.to_a.map(&:first)

    assert_equal 5, stack.size
    assert_includes stack, Lennarb::Middleware::RequestLogger
    assert_includes stack, Rack::Runtime
    assert_includes stack, Rack::Head
    assert_includes stack, Rack::ETag
    assert_includes stack, Rack::ShowExceptions
  end

  test "adds middleware to stack" do
    sample_middleware = Class.new

    app = Lennarb::App.new do
      middleware do
        use sample_middleware
      end
    end

    stack = app.middleware.to_a.map(&:first)

    assert_includes stack, sample_middleware
    assert_equal 6, stack.size
  end

  test "must respond to routes" do
    app = Lennarb::App.new

    assert_respond_to app, :routes
  end

  test "prevents app from being initialized twice" do
    app = Lennarb::App.new
    app.initialize!

    assert_raises(Lennarb::App::AlreadyInitializedError) { app.initialize! }
  end

  test "helpers are accessible in routes" do
    test_app_class = Class.new(Lennarb::App)
    my_app = test_app_class.new do
      helpers do
        def greet(name)
          "Hello, #{name}!"
        end
      end

      routes do
        get "/greet/:name" do |req, res|
          res.text(greet(req.params[:name]))
        end
      end
    end

    my_app.initialize!

    def app = my_app

    env = Rack::MockRequest.env_for("/greet/Ari")
    status, _, body = my_app.call(env)

    assert_equal 200, status
    assert_equal "Hello, Ari!", body.first
  end

  test "helpers with module" do
    app_class = Class.new(Lennarb::App)
    test_helpers = Module.new do
      def greet(name)
        "Hello, #{name}!"
      end
    end

    app_class.helpers(test_helpers)

    assert_includes app_class.helpers, test_helpers
  end

  test "initialize! does not freeze the class routes" do
    app_class = Class.new(Lennarb::App) do
      get("/a") { |req, res| res.text("a") }
    end

    app_class.new.initialize!

    refute app_class.routes.frozen?
  end

  test "routes can still be registered after the first boot" do
    app_class = Class.new(Lennarb::App) do
      get("/a") { |req, res| res.text("a") }
    end
    app_class.new.initialize!

    app_class.get("/b") { |req, res| res.text("b") }

    block, _ = app_class.routes.match_route(["b"], :GET)
    refute_nil block
  end

  test "each booted instance holds its own frozen snapshot" do
    app_class = Class.new(Lennarb::App) do
      get("/a") { |req, res| res.text("a") }
    end

    first = app_class.new.initialize!
    app_class.get("/b") { |req, res| res.text("b") }
    second = app_class.new.initialize!

    refute first.routes.equal?(app_class.routes)
    assert first.routes.frozen?
    assert_nil first.routes.match_route(["b"], :GET).first
    refute_nil second.routes.match_route(["b"], :GET).first
  end

  test "a nested route added after boot does not leak into the snapshot" do
    app_class = Class.new(Lennarb::App) do
      get("/posts") { |req, res| res.text("posts") }
    end
    booted = app_class.new.initialize!

    app_class.get("/posts/:id") { |req, res| res.text("show") }

    assert_nil booted.routes.match_route(["posts", "1"], :GET).first
    refute_nil booted.routes.match_route(["posts"], :GET).first
  end

  test "two instances of the same app class boot without colliding" do
    app_class = Class.new(Lennarb::App) do
      get("/a") { |req, res| res.text("a") }
    end

    app_class.new.initialize!

    app_class.new.initialize! # must not raise
  end
end
