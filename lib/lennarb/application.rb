module Lennarb
  class Application < App
    def initialize!
      super

      freeze!
    end

    # The middleware stack.
    #
    # @returns [Lennarb::Middleware::Stack]
    #
    def middleware
      @middleware = default_middleware_stack
      @middleware.instance_eval(&block) if block_given?
      @middleware
    end

    # The Rack app.
    #
    # @override Base#app. See {Lennarb::Base#app} for more details.
    #
    def app
      @app ||= begin
        stack = middleware.to_a

        request_handler = Application::RequestHandler.new(self)

        Rack::Builder.app do
          stack.each { |middleware, args, block| use(middleware, *args, &block) }
          run request_handler
        end
      end
    end

    # Call the app.
    #
    # @parameter [Hash] env
    #
    def call(env)
      env[RACK_LENNA_BASE] = self
      Dir.chdir(root) { return app.call(env) }
    end

    # Call the app.
    #
    # @parameter [Hash] env
    #
    # def call(env)
    #   env[RACK_LENNA_APP] = self
    #   Dir.chdir(root) { return app.call(env) }
    # end

    # The default middleware stack.
    # It includes the following middlewares:
    #
    # - Rack::CommonLogger
    # - Rack::Runtime
    # - Rack::Head
    # - Rack::Etag
    # - Lennarb::Middleware::LennaHeader
    # - Rack::ShowExceptions (only in development)
    #
    # @returns [Array]
    #
    def default_middleware_stack
      MiddlewareStack.new.tap do |middleware|
        middleware.use(Rack::CommonLogger)
        middleware.use(Rack::Runtime)
        middleware.use(Rack::Head)
        middleware.use(Rack::ETag)
        middleware.use Rack::ShowExceptions if env.development?
      end
    end
  end
end
