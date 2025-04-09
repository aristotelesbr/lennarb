require "test_helper"

class AppTest < Minitest::Test
  setup do
    Lennarb::ENV_NAMES.each { ENV.delete(it) }
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
end
