module Lennarb
  # Application class that extends Base with routing capabilities.
  # This class adds routing and request handling to the Base class,
  # providing a complete web application framework.
  #
  # @example Creating a simple application
  #   class Blog < Lennarb::App
  #     get "/" do |req, res|
  #       res.html("<h1>Welcome to my blog</h1>")
  #     end
  #
  #     get "/posts/:id" do |req, res|
  #       res.json({ id: req.params[:id], title: "Post Title" })
  #     end
  #   end
  #
  # @since 1.0.0
  class App < Base
    include Routing

    # The Rack app with all middlewares and routing.
    # This builds a middleware stack around the request handler.
    #
    # @return [#call] The Rack application
    # @since 1.0.0
    def app
      @app ||= begin
        request_handler = build_request_handler

        stack = middleware.to_a

        Rack::Builder.app do
          stack.each { |middleware, args, block| use(middleware, *args, &block) }
          run request_handler
        end
      end
    end

    # Call the app.
    # This method is called by Rack when a request is received.
    # It overrides the Base#call method to avoid duplicating logs.
    #
    # @param [Hash] env The Rack environment
    # @return [Array(Integer, Hash, #each)] The Rack response
    # @since 1.0.0
    def call(env)
      env[RACK_LENNA_APP] = self

      app.call(env)
    end

    # Define the app's middleware stack with default middlewares.
    # This method initializes the middleware stack with common middlewares
    # and allows adding additional middlewares via a block.
    #
    # @yield [middleware] Block to configure middleware
    # @return [Lennarb::MiddlewareStack] the middleware stack
    # @since 1.4.0
    #
    # @example Adding custom middleware
    #   middleware do
    #     use MyCustomMiddleware
    #   end
    def middleware(&block)
      @middleware ||= default_middleware_stack
      @middleware.instance_eval(&block) if block_given?
      @middleware
    end

    # Build a request handler with routing support.
    # This creates a handler that processes requests according to
    # the defined routes.
    #
    # @return [Lennarb::RequestHandler] The request handler
    # @since 1.4.0
    # @api protected
    protected def build_request_handler
      RequestHandler.new(self)
    end

    # The default middleware stack.
    # This defines the standard middlewares that are applied to all
    # App instances.
    #
    # @return [Lennarb::MiddlewareStack] The default middleware stack
    # @since 1.4.0
    # @api private
    private def default_middleware_stack
      stack = MiddlewareStack.new
      stack.use(Rack::CommonLogger)
      stack.use(Rack::Runtime)
      stack.use(Rack::Head)
      stack.use(Rack::ETag)
      stack.use Rack::ShowExceptions if env.development?
      stack
    end

    # Freeze the app.
    # This freezes both the app and its routes.
    #
    # @return [void]
    # @since 1.4.0
    def freeze!
      super
      routes.freeze if respond_to?(:routes)
    end
  end
end
