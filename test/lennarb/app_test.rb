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

  test "mounts controller" do
    app = Lennarb::App.new do
      mount PostsController
    end

    assert_includes app.mounted_apps, PostsController
  end

  test "match routes by controller" do
    app = Lennarb::App.new do
      mount PostsController
    end

    app.initialize!

    block, _ = app.routes.match_route(["posts"], :GET)

    refute_nil(block)
  end

  test "sets default middleware stack" do
    ENV["LENNA_ENV"] = "development"
    app = Lennarb::App.new
    stack = app.middleware.to_a.map(&:first)

    assert_equal 0, stack.size
  end

  test "must be respond to routes" do
    app = Lennarb::App.new

    assert_respond_to app, :routes
  end

  test "prevents app from being initialized twice" do
    app = Lennarb::App.new
    app.initialize!

    assert_raises(Lennarb::App::AlreadyInitializedError) { app.initialize! }
  end

  test "prevents app from having the environment set after initialization" do
    app = Lennarb::App.new
    app.initialize!

    assert_raises(Lennarb::App::AlreadyInitializedError) { app.env = :test }
  end
end
