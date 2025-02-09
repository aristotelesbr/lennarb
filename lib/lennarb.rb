# Core extensions
#
require "pathname"
require "rack"
require "bundler"

require_relative "lennarb/request"
require_relative "lennarb/response"
require_relative "lennarb/route_node"
require_relative "lennarb/version"
require_relative "lennarb/constansts"

class Lennarb
  class LennarbError < StandardError; end

  def initialize
    @_mutex ||= Mutex.new
    yield self if block_given?
  end

  HTTP_METHODS.each do |http_method|
    define_method(http_method.downcase) do |path, &block|
      add_route(path, http_method, block)
    end
  end

  def root
    @root ||= RouteNode.new
  end

  def app
    @app ||= begin
      request_handler = ->(env) { process_request(env) }

      Rack::Builder.app do
        run request_handler
      end
    end
  end

  def initializer!
    Bundler.require(:default, ENV["LENNA_ENV"] || "development")

    root.freeze
    app.freeze
  end

  def call(env) = @_mutex.synchronize { app.call(env) }

  def add_route(path, http_method, block)
    parts = path.split("/").reject(&:empty?)
    root.add_route(parts, http_method, block)
  end

  private def process_request(env)
    http_method = env[Rack::REQUEST_METHOD].to_sym
    parts = env[Rack::PATH_INFO].split("/").reject(&:empty?)

    block, params = root.match_route(parts, http_method)
    return [404, {"content-type" => Response::ContentType[:TEXT]}, ["Not Found"]] unless block

    res = Response.new
    req = Request.new(env, params)

    catch(:halt) do
      instance_exec(req, res, &block)
      res.finish
    end
  rescue => e
    [500, {"content-type" => Response::ContentType[:TEXT]}, ["Internal Server Error - #{e.message}"]]
  end
end
