require "test_helper"

class AppTest < Minitest::Test
  setup do
    Lennarb::ENV_NAMES.each { ENV.delete(_1) }
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

  test "mounts apps with path" do
    sample_app = Class.new(Lennarb::App)

    app = Lennarb::Base.new do
      mount sample_app, at: "/example"
    end

    assert_equal sample_app, app.mounted_apps["/example"]
  end

  test "mounts controller at root path by default" do
    sample_app = Class.new(Lennarb::App)

    app = Lennarb::Base.new do
      mount sample_app
    end

    assert_equal sample_app, app.mounted_apps["/"]
  end

  test "sets default middleware stack" do
    ENV["LENNA_ENV"] = "development"
    app = Lennarb::App.new
    stack = app.middleware.to_a.map(&:first)

    assert_equal 5, stack.size
    assert_includes stack, Rack::CommonLogger
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

  test "must respond to mount" do
    app = Lennarb::App.new

    assert_respond_to app, :mount
  end

  test "mount raises ArgumentError for invalid component" do
    app = Lennarb::App.new
    invalid_component = Class.new

    assert_raises(ArgumentError, "Component must be a Lennarb::App subclass") do
      app.mount(invalid_component, at: "/invalid")
    end
  end

  test "prevents app from being initialized twice" do
    app = Lennarb::App.new
    app.initialize!

    assert_raises(Lennarb::App::AlreadyInitializedError) { app.initialize! }
  end

  test "mounted apps are accessible via url map" do
    app = Lennarb::App.new
    sample_app = Class.new(Lennarb::App)
    app.mount(sample_app, at: "/example")
    app.initialize!

    rack_app = app.app

    env = Rack::MockRequest.env_for("/example")
    status, _, _ = rack_app.call(env)

    assert_kind_of Integer, status
  end

  test "helpers are accessible in routes" do
    app = Lennarb::App.new do
      helpers do
        def greet(name)
          "Hello, #{name}!"
        end
      end

      get "/greet/:name" do |req, res|
        res.text(greet(req.params[:name]))
      end
    end

    app.initialize!

    env = Rack::MockRequest.env_for("/greet/Ari")
    status, _, body = app.app.call(env)

    assert_equal 200, status
    assert_equal "Hello, Ari!", body.first
  end
end
