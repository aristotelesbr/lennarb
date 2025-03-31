module Lennarb
  # Base class for the request handler.
  #
  class RequestHandler
    attr_reader :app

    # Initialize the request handler.
    # @param [Lennarb::App] app
    def initialize(app)
      @app = app
    end

    # Call the app with the environment.
    # @param [Hash] env
    # @return [Array] See {Lennarb::Response#finish}
    def call(env)
      http_method = env[Rack::REQUEST_METHOD].to_sym
      parts = env[Rack::PATH_INFO].split("/").reject(&:empty?)
      block, params = app.routes.match_route(parts, http_method)

      return [404, {"content-type" => CONTENT_TYPE[:TEXT]}, ["Not Found"]] unless block

      req = Request.new(env, params)
      res = Response.new

      catch(:halt) do
        app.class.hook_handler.run_before_hooks(req, res)
        block.call(req, res, params || {})
        app.class.hook_handler.run_after_hooks(req, res)
        res.finish
      rescue Lennarb::Error => error
        [500, {"content-type" => CONTENT_TYPE[:TEXT]}, ["Internal Server Error (#{error.message})"]]
      rescue NameError => e
        [500, {"content-type" => "text/plain"}, ["NameError: #{e.message} (#{e.backtrace.first})"]]
      end
    end
  end
end
