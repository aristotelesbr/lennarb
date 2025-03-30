require "test_helper"

class BaseTest < Minitest::Test
  setup do
    Lennarb::ENV_NAMES.each { ENV.delete(_1) }
  end

  test "initializes with default values" do
    base = Lennarb::Base.new

    assert_equal Pathname.pwd, base.root
    assert_instance_of Lennarb::Environment, base.env
    assert base.env.development?
    assert_instance_of Hash, base.mounted_apps
    assert_empty base.mounted_apps
    refute base.initialized?
  end

  test "initializes with block" do
    called = false
    Lennarb::Base.new do
      called = true
    end

    assert called
  end

  test "sets and gets root directory" do
    base = Lennarb::Base.new
    new_root = Pathname("/tmp")

    base.root = new_root

    assert_equal new_root, base.root
  end

  test "initialize! marks app as initialized" do
    base = Lennarb::Base.new
    refute base.initialized?

    base.initialize!

    assert base.initialized?
  end

  test "prevents initialization twice" do
    base = Lennarb::Base.new
    base.initialize!

    assert_raises(Lennarb::Base::AlreadyInitializedError) { base.initialize! }
  end

  test "reads environment from ENV variables in order" do
    ENV["LENNA_ENV"] = "production"
    base = Lennarb::Base.new

    assert base.env.production?
  end

  test "sets environment" do
    base = Lennarb::Base.new
    base.env = :production

    assert base.env.production?
  end

  test "prevents changing environment after initialization" do
    base = Lennarb::Base.new
    base.initialize!

    assert_raises(Lennarb::Base::AlreadyInitializedError) { base.env = :test }
  end

  test "defines configuration" do
    base = Lennarb::Base.new

    base.config do
      optional :database_url, string, "postgres://localhost/app"
    end

    assert_equal "postgres://localhost/app", base.config.database_url
  end

  test "defines configuration with empty envs" do
    base = Lennarb::Base.new

    base.config do
      optional :key1, string, "value1"
    end

    assert_equal "value1", base.config.key1
  end

  test "defines configuration with specific environment" do
    base = Lennarb::Base.new
    base.env = :production

    base.config :production do
      optional :key1, string, "production-value"
    end

    base.config :development do
      optional :key1, string, "development-value"
    end

    assert_equal "production-value", base.config.key1
  end

  test "defines configuration without a block" do
    base = Lennarb::Base.new

    config = base.config

    assert_instance_of Lennarb::Config, config
  end

  test "defines middleware stack" do
    sample_middleware = Class.new

    base = Lennarb::Base.new do
      middleware do
        use sample_middleware
      end
    end

    assert_includes base.middleware.to_a.map(&:first), sample_middleware
  end

  test "defines middleware stack without block" do
    base = Lennarb::Base.new

    middleware = base.middleware

    assert_instance_of Lennarb::MiddlewareStack, middleware
    assert_empty middleware.to_a
  end

  test "mounts application at specified path" do
    app_class = Class.new(Lennarb::App)
    base = Lennarb::Base.new

    base.mount(app_class, at: "/example")

    assert_equal app_class, base.mounted_apps["/example"]
  end

  test "mounts application at root when path is nil" do
    app_class = Class.new(Lennarb::App)
    base = Lennarb::Base.new

    base.mount(app_class)

    assert_equal app_class, base.mounted_apps["/"]
  end

  test "raises error when mounting invalid component" do
    base = Lennarb::Base.new

    error1 = assert_raises(ArgumentError) do
      base.mount("not a class", at: "/example")
    end
    assert_equal "Component must be a Lennarb::App subclass", error1.message

    non_app_class = Class.new
    error2 = assert_raises(ArgumentError) do
      base.mount(non_app_class, at: "/example")
    end
    assert_equal "Component must be a Lennarb::App subclass", error2.message
  end

  test "inherits mounted apps from class definition" do
    app_class = Class.new(Lennarb::App)
    base_class = Class.new(Lennarb::Base)
    base_class.mount(app_class, at: "/example")

    base = base_class.new

    assert_equal app_class, base.mounted_apps["/example"]
  end

  test "normalizes mount paths with various inputs" do
    base = Lennarb::Base.new

    # Path without leading slash
    assert_equal "/example", base.send(:normalize_mount_path, "example")

    # Path with leading slash
    assert_equal "/example", base.send(:normalize_mount_path, "/example")

    # Path with trailing slash
    assert_equal "/example", base.send(:normalize_mount_path, "/example/")

    # Root path
    assert_equal "/", base.send(:normalize_mount_path, "/")
  end

  test "builds url map with mounted apps" do
    app_class = Class.new(Lennarb::App)
    base = Lennarb::Base.new
    base.mount(app_class, at: "/example")

    url_map = base.send(:build_url_map)

    assert_instance_of Rack::URLMap, url_map
  end

  test "builds url map without mounted apps" do
    base = Lennarb::Base.new

    url_map = base.send(:build_url_map)

    assert_instance_of Rack::URLMap, url_map
  end

  test "builds url map with root mount" do
    app_class = Class.new(Lennarb::App)
    base = Lennarb::Base.new
    base.mount(app_class, at: "/")

    url_map = base.send(:build_url_map)

    assert_instance_of Rack::URLMap, url_map
  end

  test "calls app with environment" do
    base = Lennarb::Base.new
    base.initialize!

    env = Rack::MockRequest.env_for("/")
    status, headers, body = base.call(env)

    assert_equal 404, status
    assert_equal "text/plain", headers["content-type"]
    assert_equal ["Not Found"], body
  end
end
