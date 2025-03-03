module Lennarb
  # Lite implementation of app.
  #
  class App
    # This error is raised whenever the app is initialized more than once.
    AlreadyInitializedError = Class.new(StandardError)

    # The root app directory of the app.
    #
    # @return[Pathname]
    #
    attr_accessor :root

    # The current environment. Defaults to "development".
    # It can be set using the following environment variables:
    #
    # - `LENNA_ENV`
    # - `APP_ENV`
    # - `RACK_ENV`
    #
    # @return[Lennarb::Environment]
    #
    attr_reader :env

    def initialize(&)
      @initialized = false
      self.root = Pathname.pwd
      self.env = compute_env
      instance_eval(&) if block_given?
    end

    # Set the current environment. See {Lennarb::Environment} for more details.
    #
    # @param[Hash] env
    #
    def env=(env)
      raise AlreadyInitializedError if initialized?

      @env = Environment.new(env)
    end

    # Mount an app at a specific path.
    #
    # @param[Object] The controller|app to mount.
    #
    # @return[void]
    #
    # @example
    #
    #   class PostController
    #     extend Lennarb::Routes::Mixin
    #
    #     get "/post/:id" do |req, res|
    #       res.text("Post ##{req.params[:id]}")
    #     end
    #   end
    #
    #  MyApp = Lennarb::App.new do
    #    routes do
    #      mount PostController
    #    end
    #
    def mount(*controllers)
      controllers.each do |controller|
        raise ArgumentError, "Controller must respond to :routes" unless controller.respond_to?(:routes)

        self.controllers << controller
      end
    end

    # Define the app's middleware stack. See {Lennarb::Middleware::Stack} for more details.
    #
    # @return[Lennarb::MiddlewareStack]
    #
    def middleware(&)
      @middleware ||= MiddlewareStack.new(self)
      @middleware.instance_eval(&) if block_given?
      @middleware
    end

    # Define the app's configuration. See {Lennarb::Config}.
    #
    # @return[Lennarb::Config]
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
    # @return[Lennarb::RouteNode]
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

        stack = middleware.to_a

        Rack::Builder.app do
          stack.each { |middleware, args, block| use(middleware, *args, &block) }

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
    # @return[Boolean]
    #
    def initialized? = @initialized

    # Initialize the app.
    #
    # @return[void]
    #
    def initialize!
      raise AlreadyInitializedError if initialized?

      if controllers.any?
        controllers.each do
          routes.store.merge!(it.routes.store)
        end
      end

      @initialized = true
    end

    # Freeze the app.
    #
    # @return[void]
    #
    def freeze!
      app.freeze
      routes.freeze
    end

    # Call the app.
    #
    # @param[Hash] env
    #
    def call(env)
      env[RACK_LENNA_APP] = self
      Dir.chdir(root) { return app.call(env) }
    end

    # Compute the current environment.
    #
    # @return[String]
    #
    # @private
    #
    private def compute_env
      env = ENV_NAMES.map { ENV[_1] }.compact.first.to_s

      env.empty? ? "development" : env
    end
  end
end
