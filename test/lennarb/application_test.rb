require "test_helper"

class ApplicationTest < Minitest::Test
  setup do
    Lennarb::ENV_NAMES.each { ENV.delete(it) }
  end

  test "uses LENNA_ENV as the env value" do
    ENV["LENNA_ENV"] = "production"

    assert Lennarb::Application.new.env.production?
  end

  test "uses RACK_ENV as the env value" do
    ENV["RACK_ENV"] = "production"

    assert Lennarb::Application.new.env.production?
  end

  test "sets default middleware stack" do
    ENV["LENNA_ENV"] = "development"
    app = Lennarb::Application.new
    stack = app.middleware.to_a.map(&:first)

    assert_equal Rack::CommonLogger, stack[0]
    assert_equal Rack::Runtime, stack[1]
    assert_equal Rack::Head, stack[2]
    assert_equal Rack::ETag, stack[3]
    assert_equal Rack::ShowExceptions, stack[4]

    assert_equal 5, stack.size
  end

  test "must be respond to routes" do
    app = Lennarb::Application.new

    assert_raises(ArgumentError) { app.mount(Object.new) }
  end

  test "mounts controller" do
    app = Lennarb::Application.new do
      mount PostsController
    end

    assert_includes app.controllers, PostsController
  end
end
