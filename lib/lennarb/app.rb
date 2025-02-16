module Lennarb
  class App
    # This error is raised whenever the app is initialized more than once.
    AlreadyInitializedError = Class.new(StandardError)

    # The routes directory of the app.
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

    # Define a route for the given HTTP method.
    #
    # @parameter [String] path
    # @parameter [Proc] block to be executed when the route is matched
    # @parameter [Symbol] the HTTP method
    #
    # @returns [void]
    #
    HTTP_METHODS.each do |http_method|
      define_method(http_method.downcase) do |path, &block|
        add_route(path, http_method, block)
      end
    end

    # Set the current environment. See {Lennarb::Environment} for more details.
    # @parameter [Hash] env
    #
    def env=(env)
      raise AlreadyInitializedError if initialized?

      @env = Environment.new(env)
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
      @routes ||= RouteNode.new
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

      @initialized = true

      Bundler.require(env.to_sym)

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

    # Add a route to the app.
    #
    # @parameter [String] path
    # @parameter [Symbol] http_method, use uppercase symbols
    # @parameter [Proc] block, the block to be executed when the route is matched.
    #
    # @returns [void]
    #
    # @example:
    #   routes.add_route("/hello", :GET) |req, res|
    #    res.json(message: "Hello World")
    #  end
    #
    private def add_route(path, http_method, block)
      parts = path.split("/").reject(&:empty?)
      routes.add_route(parts, http_method, block)
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
