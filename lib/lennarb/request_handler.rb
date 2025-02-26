module Lennarb
  class RequestHandler
    Lennarb::Error = Class.new(StandardError)

    attr_reader :app

    def initialize(app)
      @app = app
    end

    def call(env)
      http_method = env[Rack::REQUEST_METHOD].to_sym
      parts = env[Rack::PATH_INFO].split("/").reject(&:empty?)
      block, params = app.routes.match_route(parts, http_method)

      unless block
        return [404, {"content-type" => CONTENT_TYPE[:TEXT]}, ["Not Found"]]
      end

      req = Request.new(env, params)
      res = Response.new

      catch(:halt) do
        block.call(req, res)
        res.finish
      rescue Lennarb::Error => error
        [500, {"content-type" => CONTENT_TYPE[:TEXT]}, ["Internal Server Error (#{error.message})"]]
      end
    end
  end
end
