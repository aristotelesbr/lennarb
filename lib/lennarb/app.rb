module Lennarb
  # Main application class with hooks and helpers support
  class App
    class << self
      attr_writer :app
      # Rack environment variable name
      #
      # @return [String] The environment variable name
      def app
        @app ||= self
      end

      # Define helper methods for the application
      #
      # @yield Block containing helper definitions
      # @return [Module] The helpers module
      def helpers(mod_or_block = nil, &block)
        Helpers.define(self, mod_or_block, &block)
      end

      # Define a before hook
      #
      # @yield [req, res] Block to execute before route
      # @return [Array] The before hooks array
      def before(&block)
        Hooks.add(self, :before, &block)
      end

      # Define an after hook
      #
      # @yield [req, res] Block to execute after route
      # @return [Array] The after hooks array
      def after(&block)
        Hooks.add(self, :after, &block)
      end

      # Get routes for this app class
      #
      # @return [Routes] The routes instance
      def routes
        @routes ||= Routes.new
      end

      # Set up subclass
      #
      # @param [Class] subclass The new subclass
      # @return [void]
      def inherited(subclass)
        super
        # Each subclass gets its own routes
        subclass.instance_variable_set(:@routes, Routes.new)
      end

      # Define route methods for all HTTP methods
      HTTP_METHODS.each do |http_method|
        define_method(http_method.downcase) do |path, &block|
          routes.send(http_method.downcase, path, &block)
        end
      end

      # Define root route (GET /)
      #
      # @yield [req, res, params] Route block
      # @return [void]
      def root(&block)
        get("/", &block)
      end

      # Define configuration
      #
      # @param [Array<Symbol>] envs Environments
      # @yield Configuration block
      # @return [Config] The config instance
      def config(*envs, &)
        @config ||= Config.new(self)

        if block_given?
          write = envs.empty? || envs.map(&:to_sym).include?(compute_env_name)
          @config.instance_eval(&) if write
        end

        @config
      end

      # The environment name computed from ENV.
      #
      # A class has no env of its own, so environment-scoped config blocks
      # resolve it here.
      #
      # @return [Symbol] Environment name
      # @api private
      private def compute_env_name
        name = ENV_NAMES.map { |var| ENV[var] }.compact.first.to_s
        (name.empty? ? "development" : name).to_sym
      end
    end

    # Instance methods

    # Initialize a new app
    #
    # @yield [self] Configuration block
    def initialize(&block)
      @initialized = false
      @root = Pathname.pwd
      @env = Environment.new(compute_env)

      instance_eval(&block) if block_given?
    end

    # The current environment
    attr_reader :env

    # The root directory
    attr_accessor :root

    # Set environment
    #
    # @param [String, Symbol] value Environment name
    # @raise [AlreadyInitializedError] If already initialized
    # @return [Environment] The new environment
    def env=(value)
      raise AlreadyInitializedError if initialized?
      @env = Environment.new(value)
    end

    # Get the Rack app with middleware
    #
    # @return [#call] The Rack app
    def app
      @app ||= begin
        handler = build_request_handler
        stack = middleware.to_a

        Rack::Builder.app do
          stack.each { |middleware, args, block| use(middleware, *args, &block) }
          run handler
        end
      end
    end

    # Rack interface method
    #
    # @param [Hash] env Rack environment
    # @return [Array] Rack response
    def call(env)
      env[RACK_LENNA_APP] = self
      app.call(env)
    end

    # Define middleware
    #
    # @yield Block to configure middleware
    # @return [MiddlewareStack] The middleware stack
    def middleware(&block)
      @middleware_stack ||= default_middleware_stack
      @middleware_stack.instance_eval(&block) if block_given?
      @middleware_stack
    end

    # Define helpers (instance method)
    #
    # @yield Block with helper definitions
    # @return [Module] The helpers module
    def helpers(&block)
      self.class.helpers(&block)
    end

    # Define before hook (instance method)
    #
    # @yield [req, res] Before hook block
    # @return [Array] The before hooks array
    def before(&block)
      self.class.before(&block)
    end

    # Define after hook (instance method)
    #
    # @yield [req, res] After hook block
    # @return [Array] The after hooks array
    def after(&block)
      self.class.after(&block)
    end

    # Get/define routes
    #
    # @yield Block to define routes
    # @return [Routes] The routes instance
    def routes(&block)
      if block_given?
        self.class.instance_exec(&block)
      end

      # Before boot, route definitions go to the class. After boot, this
      # instance serves from its own frozen snapshot.
      @routes || self.class.routes
    end

    # Get/define configuration
    #
    # @param [Array<Symbol>] envs Environments
    # @yield Configuration block
    # @return [Config] The config instance
    def config(*envs, &)
      @config ||= self.class.config

      if block_given?
        write = envs.empty? || envs.map(&:to_sym).include?(env.name)
        @config.instance_eval(&) if write
      end

      @config
    end

    # Initialize the app
    #
    # @return [self] The initialized app
    # @raise [AlreadyInitializedError] If already initialized
    def initialize!
      raise AlreadyInitializedError if @initialized

      # Snapshot the class routes into this instance and freeze only the copy,
      # so booting an app never freezes process-global class state.
      @routes = Routes.new
      @routes.merge!(self.class.routes)
      @routes.freeze

      @initialized = true
      self
    end

    # Check if initialized
    #
    # @return [Boolean] true if initialized
    def initialized?
      @initialized
    end

    # Error for already initialized app
    AlreadyInitializedError = Class.new(StandardError)

    protected

    # Build the request handler
    #
    # @return [RequestHandler] The request handler
    def build_request_handler
      RequestHandler.new(self)
    end

    # Create default middleware stack
    #
    # @return [MiddlewareStack] The middleware stack
    private def default_middleware_stack
      stack = MiddlewareStack.new
      stack.use(Lennarb::Middleware::RequestLogger)
      stack.use(Rack::Runtime)
      stack.use(Rack::Head)
      stack.use(Rack::ETag)
      stack.use(Rack::ShowExceptions) if env.development?
      stack
    end

    # Compute environment from ENV variables
    #
    # @return [String] Environment name
    private def compute_env
      env = ENV_NAMES.map { |name| ENV[name] }.compact.first.to_s
      env.empty? ? "development" : env
    end
  end
end
