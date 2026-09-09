module Lennarb
  # Handles requests and executes routes with helpers and hooks.
  #
  class RequestHandler
    attr_reader :app

    # Initialize the request handler
    #
    # @param [Lennarb::App] app The application instance
    def initialize(app)
      @app = app
    end

    # Handle a request according to Rack interface
    #
    # @param [Hash] env The Rack environment
    # @return [Array] Rack response [status, headers, body]
    def call(env)
      http_method = env[Rack::REQUEST_METHOD].to_sym
      parts = env[Rack::PATH_INFO].split("/").reject(&:empty?)
      block, params = app.routes.match_route(parts, http_method)

      return [404, {"content-type" => CONTENT_TYPE[:TEXT]}, ["Not Found"]] unless block

      req = Request.new(env, params || {})
      res = Response.new

      catch(:halt) do
        context = create_context

        Hooks.execute(context, app.class, :before, req, res)

        context.instance_exec(req, res, params, &block)

        Hooks.execute(context, app.class, :after, req, res)

        res.finish
      rescue => e
        # In development, let the exception through so Rack::ShowExceptions --
        # already in App#default_middleware_stack -- can render the backtrace.
        raise if app.env.development?

        app.class.config.logger.error("Error: #{e.message}")
        app.class.config.logger.error(e.backtrace.first)
        [500, {"content-type" => CONTENT_TYPE[:TEXT]}, ["Internal Server Error"]]
      end
    end

    private

    # Create a context object with app's helper methods
    #
    # @return [Object] A context object with helper methods
    def create_context
      context = Object.new

      context.define_singleton_method(:app) { app }

      helpers_module = Helpers.for(app.class)
      context.extend(helpers_module) if helpers_module

      context
    end
  end
end
