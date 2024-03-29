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
	# @returns [RouteNode]
	#
	attr_reader :root

	@routes = []
	# Initialize the application
	#
	# @yield { ... } The application
	#
	# @returns [Lennarb]
	#
	def initialize
		@root = RouteNode.new
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
		http_method = env.fetch('REQUEST_METHOD').to_sym
		parts       = SplitPath[env.fetch('PATH_INFO')]

		block, params = @root.match_route(parts, http_method)
		return [404, { 'content-type' => 'text/plain' }, ['Not Found']] unless block

		res = Response.new
		req = Request.new(env, params)
		instance_exec(req, res, &block)

		res.finish
	end

	# Add a routes
	#
	# @parameter [String] path
	# @parameter [Proc] block
	#
	# @returns [void]
	#
	def get(path, &block)    = add_route(path, :GET, block)
	def put(path, &block)    = add_route(path, :PUT, block)
	def post(path, &block)   = add_route(path, :POST, block)
	def head(path, &block)   = add_route(path, :HEAD, block)
	def patch(path, &block)  = add_route(path, :PATCH, block)
	def delete(path, &block) = add_route(path, :DELETE, block)
	def options(path, &block) = add_route(path, :OPTIONS, block)

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
		@root.add_route(parts, http_method, block)
	end

	# Base class for Lennarb applications
	#
	class ApplicationBase < Lennarb
		@routes = []

		class << self
			attr_reader :routes

			# Add a route
			#
			# @parameter [String] path
			# @parameter [Proc] block
			#
			# @returns [void]
			#
			%i[get post put patch delete].each do |http_method|
				define_method(http_method) do |path, &block|
					routes << { method: http_method, path:, proc: block }
				end
			end
		end

		# Inherited hook
		#
		# @parameter [Class] subclass
		#
		# @returns [void]
		#
		def self.inherited(subclass)
			super
			subclass.instance_variable_set(:@routes, routes.dup)
		end

		# Initialize the application
		#
		# @returns [ApplicationBase]
		#
		def initialize
			super
			setup_routes
		end

		private

		# Setup the routes
		#
		# @returns [void]
		#
		def setup_routes
			self.class.routes.each do |route_info|
				__send__(route_info[:method], route_info[:path], &route_info[:proc])
			end
		end
	end
end
