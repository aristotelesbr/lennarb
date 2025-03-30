module Lennarb
  # Base class for mounting applications with middleware support.
  # This class serves as the foundation for creating modular, mountable applications
  # with middleware processing at the router level.
  #
  # @example Creating a root application
  #   class Application < Lennarb::Base
  #     # Define base-level middleware
  #     middleware do
  #       use Rack::Session::Cookie, secret: "your_secret"
  #       use Rack::Protection
  #     end
  #
  #     # Mount other applications
  #     mount(Blog, at: "/blog")
  #     mount(Admin, at: "/admin")
  #   end
  #
  # @since 1.4.0
  class Base
    # This error is raised whenever the app is initialized more than once.
    # @since 1.0.0
    AlreadyInitializedError = Class.new(StandardError)

    class << self
      # Store for mounted applications at class level
      # @return [Hash] mounted applications by path
      # @since 1.4.0
      def mounted_apps
        @mounted_apps ||= {}
      end

      # Define the app's middleware stack at class level.
      # This allows defining middleware that will be applied before
      # routing to any mounted applications.
      #
      # @yield [middleware] Block to configure middleware
      # @return [Lennarb::MiddlewareStack] the middleware stack
      # @since 1.4.0
      #
      # @example
      #   middleware do
      #     use Rack::Session::Cookie, secret: "your_secret"
      #     use Rack::Protection
      #   end
      def middleware(&block)
        @middleware ||= MiddlewareStack.new
        @middleware.instance_eval(&block) if block_given?
        @middleware
      end

      # Define the app's configuration at class level
      # @param [Array<Symbol>] envs Environments to apply the configuration to
      # @yield [config] Block to configure the application
      # @return [Lennarb::Config] the configuration
      # @since 1.4.0
      #
      # @example Configure for all environments
      #   config do
      #     set :title, "My Application"
      #   end
      #
      # @example Configure for specific environments
      #   config :development, :test do
      #     set :debug, true
      #   end
      def config(*envs, &block)
        @config ||= Config.new
        @config.instance_eval(&block) if block_given?
        @config
      end

      # Mount a component at the given path.
      # @param [Class] component The component to mount (must be a Lennarb::App subclass)
      # @param [Hash] options The mounting options
      # @option options [String] :at The path to mount the component at
      # @raise [ArgumentError] If the component is not a Lennarb::App subclass
      # @return [void]
      # @since 1.4.0
      #
      # @example
      #   mount(Blog, at: "/blog")
      #   mount(Admin, at: "/admin")
      def mount(component, at: nil)
        if component.is_a?(Class) && component < Lennarb::App
          path = normalize_mount_path(at || "/")
          mounted_apps[path] = component
        else
          raise ArgumentError, "Component must be a Lennarb::App subclass"
        end
      end

      # Called when a subclass is created
      # @param [Class] subclass The created subclass
      # @return [void]
      # @since 1.4.0
      # @api private
      def inherited(subclass)
        super
      end

      # Normalize the mount path.
      # @param [String] path The path to normalize
      # @return [String] The normalized path
      # @since 1.4.0
      # @api private
      private def normalize_mount_path(path)
        path = "/#{path}" unless path.start_with?("/")
        path = path[0..-2] if path.end_with?("/") && path != "/"
        path
      end
    end

    # The current environment.
    # @return [Lennarb::Environment] The environment
    # @since 1.0.0
    attr_reader :env

    # The root directory of the application.
    # @return [Pathname] The root directory
    # @since 1.0.0
    attr_accessor :root

    # Get the mounted applications.
    # @return [Hash] The mounted applications by path
    # @since 1.4.0
    attr_reader :mounted_apps

    # Initialize a new Base instance.
    # @yield [self] Block to configure the application
    # @return [Base] The initialized application
    # @since 1.0.0
    def initialize(&block)
      @initialized = false
      @mounted_apps = {}
      @middleware = nil
      self.root = Pathname.pwd
      @env = Environment.new(compute_env)

      # Initialize mounted applications from class definition
      self.class.mounted_apps.each do |path, app_class|
        @mounted_apps[path] = app_class
      end

      instance_eval(&block) if block_given?
    end

    # Define the app's middleware stack.
    # Middleware defined here will be applied to all requests before
    # they are routed to mounted applications.
    #
    # @yield [middleware] Block to configure middleware
    # @return [Lennarb::MiddlewareStack] the middleware stack
    # @since 1.4.0
    #
    # @example
    #   middleware do
    #     use Rack::Session::Cookie, secret: "your_secret"
    #     use Rack::Protection
    #   end
    def middleware(&block)
      @middleware ||= MiddlewareStack.new
      @middleware.instance_eval(&block) if block_given?
      @middleware
    end

    # Define the app's configuration.
    # @param [Array<Symbol>] envs Environments to apply the configuration to
    # @yield [config] Block to configure the application
    # @return [Lennarb::Config] the configuration
    # @since 1.4.0
    def config(*envs, &block)
      @config ||= Config.new

      write = block_given? &&
        (envs.map(&:to_sym).include?(env.to_sym) || envs.empty?)

      @config.instance_eval(&block) if write

      @config
    end

    # The Rack app with all middlewares and mounted applications.
    # This builds a middleware stack around the URL map of mounted applications.
    #
    # @return [#call] The Rack application
    # @since 1.0.0
    def app
      @app ||= begin
        url_map = build_url_map

        stack = middleware.to_a

        Rack::Builder.app do
          stack.each { |middleware, args, block| use(middleware, *args, &block) }
          run url_map
        end
      end
    end

    # Check if the app is initialized.
    # @return [Boolean] true if initialized, false otherwise
    # @since 1.4.0
    def initialized? = @initialized

    # Initialize the app.
    # @return [self] The initialized app
    # @raise [AlreadyInitializedError] If the app is already initialized
    # @since 1.4.0
    def initialize!
      raise AlreadyInitializedError if initialized?
      @initialized = true
      self
    end

    # Set the environment for the application.
    # @param [String, Symbol] value The environment name
    # @raise [AlreadyInitializedError] If the app is already initialized
    # @return [Lennarb::Environment] The new environment
    # @since 1.4.0
    def env=(value)
      raise AlreadyInitializedError if initialized?
      @env = Environment.new(value)
    end

    # Freeze the app.
    # @return [void]
    # @since 1.0.0
    def freeze!
      app.freeze
    end

    # Call the app - main Rack entry point.
    # This method is called by Rack when a request is received.
    #
    # @param [Hash] env The Rack environment
    # @return [Array(Integer, Hash, #each)] The Rack response
    # @since 1.0.0
    def call(env)
      # Store reference to the current app in the env
      env[RACK_LENNA_APP] = self

      # Call the app with middlewares
      app.call(env)
    end

    # Mount a component at the given path (instance method)
    # @param [Class] component The component to mount (must be a Lennarb::App subclass)
    # @param [Hash] options The mounting options
    # @option options [String] :at The path to mount the component at
    # @raise [ArgumentError] If the component is not a Lennarb::App subclass
    # @return [void]
    # @since 1.4.0
    #
    # @example
    #   mount(Blog, at: "/blog")
    def mount(component, at: nil)
      if component.is_a?(Class) && component < Lennarb::App
        path = normalize_mount_path(at || "/")
        @mounted_apps[path] = component
      else
        raise ArgumentError, "Component must be a Lennarb::App subclass"
      end
    end

    # Build the URL map with all mounted applications.
    # @return [Rack::URLMap] The URL map
    # @since 1.4.0
    # @api private
    private def build_url_map
      url_map = {}

      if mounted_apps.any?
        mounted_apps.each do |path, app_class|
          app_instance = app_class.new
          app_instance.initialize!
          url_map[path] = app_instance
        end
      end

      # Only add root handler if there's no mount at root path
      url_map["/"] = build_request_handler unless url_map.key?("/")

      Rack::URLMap.new(url_map)
    end

    # Build a simple request handler for the root path.
    # @return [#call] The request handler
    # @since 1.4.0
    # @api protected
    protected def build_request_handler
      ->(env) { [404, {"content-type" => "text/plain"}, ["Not Found"]] }
    end

    # Normalize the mount path.
    # @param [String] path The path to normalize
    # @return [String] The normalized path
    # @since 1.4.0
    # @api private
    private def normalize_mount_path(path)
      path = "/#{path}" unless path.start_with?("/")
      path = path[0..-2] if path.end_with?("/") && path != "/"
      path
    end

    # Compute the current environment from environment variables.
    # @return [String] The environment name
    # @since 1.4.0
    # @api private
    private def compute_env
      env = ENV_NAMES.map { ENV[_1] }.compact.first.to_s
      env.empty? ? "development" : env
    end
  end
end
