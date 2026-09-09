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
      parts = split_path(env[Rack::PATH_INFO])
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

    # Split a request path into decoded segments.
    #
    # Segments are decoded after splitting, so a percent-encoded slash stays
    # inside its segment instead of splitting the path. The escape check keeps
    # the common path free of the decoding cost.
    #
    # @param [String] path The raw PATH_INFO
    # @return [Array<String>] The decoded segments
    def split_path(path)
      parts = path.split("/").reject(&:empty?)
      return parts unless path.include?("%")

      parts.map! { |part| Rack::Utils.unescape_path(part) }
    end

    # The context class for this app, compiled once.
    #
    # Safe to memoize: Helpers.for always returns the same Module object for a
    # given app class, and Ruby's include is live, so helpers defined after the
    # first request still resolve through it.
    #
    # @return [Class] The context class
    def context_class
      @context_class ||= begin
        helpers_module = Helpers.for(app.class)

        Class.new do
          def initialize(app)
            @app = app
          end

          attr_reader :app

          include helpers_module
        end
      end
    end

    # Create a context object with app's helper methods
    #
    # @return [Object] A context object with helper methods
    def create_context
      context_class.new(app)
    end
  end
end
