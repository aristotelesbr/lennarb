# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

# Core extensions
#
require 'pathname'
require 'rack'

require_relative 'lennarb/plugin'
require_relative 'lennarb/request'
require_relative 'lennarb/response'
require_relative 'lennarb/route_node'
require_relative 'lennarb/version'

class Lennarb
  class LennarbError < StandardError; end

  attr_reader :_root, :_plugins, :_loaded_plugins, :_middlewares, :_app

  def self.use(middleware, *args, &block)
    @_middlewares ||= []
    @_middlewares << [middleware, args, block]
  end

  def self.get(path, &block)     = add_route(path, :GET, block)
  def self.put(path, &block)     = add_route(path, :PUT, block)
  def self.post(path, &block)    = add_route(path, :POST, block)
  def self.head(path, &block)    = add_route(path, :HEAD, block)
  def self.patch(path, &block)   = add_route(path, :PATCH, block)
  def self.delete(path, &block)  = add_route(path, :DELETE, block)
  def self.options(path, &block) = add_route(path, :OPTIONS, block)

  def self.inherited(subclass)
    super
    subclass.instance_variable_set(:@_root, RouteNode.new)
    subclass.instance_variable_set(:@_plugins, [])
    subclass.instance_variable_set(:@_middlewares, @_middlewares&.dup || [])

    Plugin.load_defaults! if Plugin.load_defaults?
  end

  def self.plugin(plugin_name, *, &)
    @_loaded_plugins ||= {}
    @_plugins        ||= []

    return if @_loaded_plugins.key?(plugin_name)

    plugin_module = Plugin.load(plugin_name)
    plugin_module.configure(self, *, &) if plugin_module.respond_to?(:configure)

    @_loaded_plugins[plugin_name] = plugin_module
    @_plugins << plugin_name
  end

  def self.freeze!
    app = new
    app.freeze!
    app
  end

  def self.add_route(path, http_method, block)
    @_root ||= RouteNode.new
    parts = path.split('/').reject(&:empty?)
    @_root.add_route(parts, http_method, block)
  end

  private_class_method :add_route

  def initialize
    @_mutex = Mutex.new
    @_root             = self.class.instance_variable_get(:@_root)&.dup           || RouteNode.new
    @_plugins          = self.class.instance_variable_get(:@_plugins)&.dup        || []
    @_loaded_plugins   = self.class.instance_variable_get(:@_loaded_plugins)&.dup || {}
    @_middlewares      = self.class.instance_variable_get(:@_middlewares)&.dup    || []

    build_app

    yield self if block_given?
  end

  def call(env) = @_mutex.synchronize { @_app.call(env) }

  def freeze!
    return self if @_mounted

    @_root.freeze
    @_plugins.freeze
    @_loaded_plugins.freeze
    @_middlewares.freeze
    @_app.freeze if @_app.respond_to?(:freeze)
    self
  end

  def get(path, &block)     = add_route(path, :GET, block)
  def put(path, &block)     = add_route(path, :PUT, block)
  def post(path, &block)    = add_route(path, :POST, block)
  def head(path, &block)    = add_route(path, :HEAD, block)
  def patch(path, &block)   = add_route(path, :PATCH, block)
  def delete(path, &block)  = add_route(path, :DELETE, block)
  def options(path, &block) = add_route(path, :OPTIONS, block)

  def plugin(plugin_name, *, &)
    return if @_loaded_plugins.key?(plugin_name)

    plugin_module = Plugin.load(plugin_name)
    self.class.extend plugin_module::ClassMethods     if plugin_module.const_defined?(:ClassMethods)
    self.class.include plugin_module::InstanceMethods if plugin_module.const_defined?(:InstanceMethods)
    plugin_module.configure(self, *, &)               if plugin_module.respond_to?(:configure)
    @_loaded_plugins[plugin_name] = plugin_module
    @_plugins << plugin_name
  end

  private

  def build_app
    @_app = method(:process_request)

    @_middlewares.reverse_each do |middleware, args, block|
      @_app = middleware.new(@_app, *args, &block)
    end
  end

  def process_request(env)
    http_method = env[Rack::REQUEST_METHOD].to_sym
    parts       = env[Rack::PATH_INFO].split('/').reject(&:empty?)

    block, params = @_root.match_route(parts, http_method)
    return not_found unless block

    res = Response.new
    req = Request.new(env, params)

    catch(:halt) do
      instance_exec(req, res, &block)
      res.finish
    end
  rescue StandardError => e
    handle_error(e)
  end

  def handle_error(error)
    case error
    when ArgumentError
      [400, { 'content-type' => 'text/plain' }, ["Bad Request: #{error.message}"]]
    else
      [500, { 'content-type' => 'text/plain' }, ["Internal Server Error: #{error.message}"]]
    end
  end

  def not_found = [404, { 'content-type' => 'text/plain' }, ['Not Found']]

  def add_route(path, http_method, block)
    parts = path.split('/').reject(&:empty?)
    @_root.add_route(parts, http_method, block)
  end
end
