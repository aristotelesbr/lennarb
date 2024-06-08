# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

# Core extensions
#
require 'pathname'
require 'rack'

# Base class for Lennarb
#
require_relative 'lennarb/application/base'
require_relative 'lennarb/plugin'
require_relative 'lennarb/request'
require_relative 'lennarb/response'
require_relative 'lennarb/route_node'
require_relative 'lennarb/version'

class Lennarb
	# Error class
	#
	class LennarbError < StandardError; end

	# @attribute [r] root
	# @returns [RouteNode]
	#
	attr_reader :_root

	# @attribute [r] applied_plugins
	# @returns [Array]
	#
	attr_reader :_applied_plugins

	# Initialize the application
	#
	# @yield { ... } The application
	#
	# @returns [Lennarb]
	#
	def initialize
		@_root = RouteNode.new
		@_applied_plugins = []
		yield self if block_given?
	end

	# Split a path into parts
	#
	# @parameter [String] path
	#
	# @returns [Array] parts. Ex. ['users', ':id']
	#
	SplitPath = ->(path) { path.split('/').reject(&:empty?) }
	private_constant :SplitPath

	# Call the application
	#
	# @parameter [Hash] env
	#
	# @returns [Array] response
	#
	def call(env)
		http_method = env[Rack::REQUEST_METHOD].to_sym
		parts       = SplitPath[env[Rack::PATH_INFO]]

		block, params = @_root.match_route(parts, http_method)
		return [404, { 'content-type' => 'text/plain' }, ['Not Found']] unless block

		@res = Response.new
		req  = Request.new(env, params)

		catch(:halt) do
			instance_exec(req, @res, &block)
			@res.finish
		end
	end

	# Freeze the routes
	#
	# @returns [void]
	#
	def freeze! = @_root.freeze

	# Add a routes
	#
	# @parameter [String] path
	# @parameter [Proc] block
	#
	# @returns [void]
	#
	def get(path, &block)     = add_route(path, :GET, block)
	def put(path, &block)     = add_route(path, :PUT, block)
	def post(path, &block)    = add_route(path, :POST, block)
	def head(path, &block)    = add_route(path, :HEAD, block)
	def patch(path, &block)   = add_route(path, :PATCH, block)
	def delete(path, &block)  = add_route(path, :DELETE, block)
	def options(path, &block) = add_route(path, :OPTIONS, block)

	# Add plugin to extend the router
	#
	# @parameter [String] plugin_name
	# @parameter [args]  *args
	# @parameter [Block] block
	#
	# @returns [void]
	#
	def plugin(plugin_name, *, &)
		return if @_applied_plugins.include?(plugin_name)

		plugin_module = Plugin.load(plugin_name)
		extend plugin_module::InstanceMethods         if defined?(plugin_module::InstanceMethods)
		self.class.extend plugin_module::ClassMethods if defined?(plugin_module::ClassMethods)
		plugin_module.setup(self.class, *, &)         if plugin_module.respond_to?(:setup)

		@_applied_plugins << plugin_name
	end

	private

	# Add a route
	#
	# @parameter [String] path
	# @parameter [String] http_method
	# @parameter [Proc] block
	#
	# @returns [void]
	#
	def add_route(path, http_method, block)
		parts = SplitPath[path]
		@_root.add_route(parts, http_method, block)
	end
end
