module Lennarb
  class App
    # This error is raised whenever the app is initialized more than once.
    AlreadyInitializedError = Class.new(StandardError)

    # The root app directory of the app.
    #
    # @returns [Pathname]
    #
    attr_accessor :root

    # The current environment. Defaults to "development".
    # It can be set using the following environment variables:
    #
    # - `LENNA_ENV`
    # - `APP_ENV`
    # - `RACK_ENV`
    #
    # @returns [Lennarb::Environment]
    #
    attr_reader :env

    def initialize(&)
      @_mutex ||= Mutex.new
      @initialized = false
      self.root = Pathname.pwd
      self.env = compute_env
      instance_eval(&) if block_given?
    end

    # Set the current environment. See {Lennarb::Environment} for more details.
    #
    # @parameter [Hash] env
    #
    def env=(env)
      raise AlreadyInitializedError if initialized?

      @env = Environment.new(env)
    end

    # Mount an app at a specific path.
    #
    # @parameter [Lennarb::App] The controller to mount.
    #
    # @parameter [String] The path to mount the app.
    #
    # @returns [void]
    #
    # @example
    #
    #   class PostController
    #     include Lennarb::Routes
    #
    #     # GET /posts
    #     get "/" do |req, res|
    #       # ...
    #     end
    #   end
    #
    #  MyApp = Lennarb::App.new do
    #    routes do
    #      mount PostController, at: "/posts"
    #    end
    #
    def mount(controller)
      raise ArgumentError, "Controller must respond to :routes" unless controller.respond_to?(:routes)

      controllers << controller
    end

    # Define the app's configuration. See {Lennarb::Config}.
    #
    # @returns [Lennarb::Config]
    #
    # @example Run config on every environment
    #   app.config do
    #     mandatory :database_url, string
    #   end
    #
    # @example Run config on every a specific environment
    #   app.config :development do
    #     set :domain, "example.dev"
    #   end
    #
    # @example Run config on every a specific environment
    #   app.config :development, :test do
    #     set :domain, "example.dev"
    #   end
    #
    def config(*envs, &)
      @config ||= Config.new

      write = block_given? &&
        (envs.map(&:to_sym).include?(env.to_sym) || envs.empty?)

      @config.instance_eval(&) if write

      @config
    end

    # Define the app's route. See {Lennarb::RouteNode} for more details.
    #
    # @returns [Lennarb::RouteNode]
    #
    def routes(&)
      @routes ||= Routes.new
      @routes.instance_eval(&) if block_given?
      @routes
    end

    # The Rack app.
    #
    def app
      @app ||= begin
        request_handler = RequestHandler.new(self)

        Rack::Builder.app do
          run request_handler
        end
      end
    end

    # Store mounted app's
    #
    def controllers
      @controllers ||= []
    end
    alias_method :mounted_apps, :controllers

    # Check if the app is initialized.
    #
    # @returns [Boolean]
    #
    def initialized? = @initialized

    # Initialize the app.
    #
    # @returns [void]
    #
    def initialize!
      raise AlreadyInitializedError if initialized?

      controllers.each do
        routes.store.merge!(it.routes.store)
      end

      @initialized = true

      app.freeze
      routes.freeze
    end

    # Call the app.
    #
    # @parameter [Hash] env
    #
    def call(env)
      @_mutex.synchronize do
        env[RACK_LENNA_APP] = self
        Dir.chdir(root) { return app.call(env) }
      end
    end

    # Compute the current environment.
    #
    # @returns [String]
    #
    # @private
    #
    private def compute_env
      env = ENV_NAMES.map { ENV[_1] }.compact.first.to_s

      env.empty? ? "development" : env
    end
  end
end
