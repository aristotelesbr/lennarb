require "test_helper"

class AppTest < Minitest::Test
  setup do
    Lennarb::ENV_NAMES.each { ENV.delete(it) }
  end

  test "uses ZEE_ENV as the env value" do
    ENV["APP_ENV"] = "production"

    assert Lennarb::App.new.env.production?
  end

  test "uses APP_ENV as the env value" do
    ENV["LENNA_ENV"] = "production"

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
