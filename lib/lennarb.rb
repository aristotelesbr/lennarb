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
	def get(path, &block)    = __add_route__(path, :GET, block)
	def post(path, &block)   = __add_route__(path, :POST, block)
	def put(path, &block)    = __add_route__(path, :PUT, block)
	def patch(path, &block)  = __add_route__(path, :PATCH, block)
	def delete(path, &block) = __add_route__(path, :DELETE, block)

	# Add a route
	#
	# @parameter [String] path
	# @parameter [String] http_method
	# @parameter [Proc] block
	#
	# @returns [void]
	#
	def __add_route__(path, http_method, block)
		parts = SplitPath[path]
		@root.add_route(parts, http_method, block)
	end

	# Base module for the application. The main purpose is to include the class methods
	# and call the Lennarb instance.
	#
	module ApplicationBase
		# Include the class methods
		#
		# @parameter [Class] base
		#
		# @returns [void]
		#
		def self.included(base) = base.extend(ClassMethods)

		# Call the Lennarb instance
		#
		# @parameter [Hash] env
		#
		# @returns [Array]
		#
		def call(env) = self.class.lennarb_instance.call(env)

		# Class methods
		#
		module ClassMethods
			# Get the Lennarb instance
			#
			# @returns [Lennarb]
			#
			def lennarb_instance = @lennarb_instance ||= Lennarb.new

			# Add a route
			#
			# @parameter [String] path
			# @parameter [Proc] block
			#
			# @returns [void]
			#
			def get(path, &block)    = lennarb_instance.__add_route__(path, :GET, block)
			def put(path, &block)    = lennarb_instance.__add_route__(path, :PUT, block)
			def post(path, &block)   = lennarb_instance.__add_route__(path, :POST, block)
			def patch(path, &block)  = lennarb_instance.__add_route__(path, :PATCH, block)
			def delete(path, &block) = lennarb_instance.__add_route__(path, :DELETE, block)
		end
	end
end
