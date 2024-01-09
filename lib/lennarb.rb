# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

ENV['RACK_ENV'] ||= 'development'

# Core extensions
#
require 'pathname'
require 'rack'

# Base class for Lennarb
#
require_relative 'lennarb/request'
require_relative 'lennarb/response'
require_relative 'lennarb/route_node'
require_relative 'lennarb/version'

class Lennarb
	# Error class
	#
	class LennarbError < StandardError; end

	# @attribute [r] root
	# @return [RouteNode]
	#
	attr_reader :root

	# Initialize the application
	#
	# @yield { ... } The application
	#
	# @return [Lennarb]
	#
	def initialize
		@root = RouteNode.new
		yield self if block_given?
	end

	# Split a path into parts
	#
	# @parameter [String] path
	#
	# @return [Array] parts. Ex. ['users', ':id']
	#
	SplitPath = ->(path) { path.split('/').reject(&:empty?) }
	private_constant :SplitPath

	# Call the application
	#
	# @parameter [Hash] env
	#
	# @return [Array] response
	#
	def call(env)
		res = Response.new
		http_method = env.fetch('REQUEST_METHOD').to_sym
		parts       = SplitPath[env.fetch('PATH_INFO')]

		block, params = @root.match_route(parts, http_method)
		return [404, { 'content-type' => 'text/plain' }, ['Not Found']] unless block

		req = Request.new(env, params)
		instance_exec(req, res, &block)

		res.finish
	end

	# Add a routes
	#
	# @parameter [String] path
	# @parameter [Proc] block
	#
	# @return [void]
	#
	def get(path, &block)    = add_route(path, :GET, block)
	def post(path, &block)   = add_route(path, :POST, block)
	def put(path, &block)    = add_route(path, :PUT, block)
	def patch(path, &block)  = add_route(path, :PATCH, block)
	def delete(path, &block) = add_route(path, :DELETE, block)

	private

	# Add a route
	#
	# @parameter [String] path
	# @parameter [String] http_method
	# @parameter [Proc] block
	#
	# @return [void]
	#
	def add_route(path, http_method, block)
		parts = SplitPath[path]
		@root.add_route(parts, http_method, block)
	end
end
