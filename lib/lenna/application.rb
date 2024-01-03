# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

# The Lenna module is used to namespace the framework.
#
# @public
#
module Lenna
	# The base class is used to start the server.
	#
	# @public
	#
	class Application
		# Initialize the base class
		#
		# @yield { ... } the block to be evaluated in the context of the instance.
		#
		# @return [void | Application] Returns the instance if a block is given.
		#
		# def initialize
		# 	super
		# 	yield self if block_given?
		# end
		def initialize
			@router = Router.new
			yield self if block_given?
		end

		#	Proxy methods to add routes
		#
		# @parameter path  [String] the path to be matched
		# @parameter *     [Array]  the middlewares to be used
		# @yield { ... }            the block to be executed
		#
		# @return          [void]
		#
		# see {#add_route}
		#
		# @public `Since v0.1`
		#
		def get(path,    &) = @router.add_route(::Rack::GET, path,    &)
		def put(path,    &) = @router.add_route(::Rack::PUT, path,    &)
		def post(path,   &) = @router.add_route(::Rack::POST, path,   &)
		def delete(path, &) = @router.add_route(::Rack::DELETE, path, &)

		# This method is used to add a route to the router.
		#
		# @parameter prefix [String] the prefix to be used.
		# @yield { ... }             the block to be executed
		#
		# @return         [void]
		#
		# @public `Since v0.1`
		#
		# @example
		#   namespace '/api' do
		#     get '/users' do |req, res|
		#       res.json({ users: [] })
		#     end
		#   end
		#
		def namespace(prefix, &)
			@router.add_namespace(prefix, &)
		end

		def call(env) = dup.call!(env)

		# This method is used to call the middleware chain for each request.
		# It also sets the RACK_ENV to development if it is not set.
		#
		# @parameter env [Hash] the Rack env
		#
		# @return        [Array] the Lennarb::Response
		#
		def call!(env)
			req = Lenna::Request.new(env)
			method = env['REQUEST_METHOD']
			path = env['PATH_INFO']

			route_block, params = @router.find_route(method, path)
			if route_block
				req.params.merge!(params)
				res = Lenna::Response.new
				route_block.call(req, res)
				res.finish
			else
				[404, { 'Content-Type' => 'text/html' }, ['Not Found']]
			end
		end
	end

	# The base module is used to include the base class.
	#
	# @public
	#
	module Base
		def self.included(base)
			base.extend(ClassMethods)
		end

		module ClassMethods
			# Initialize the base module
			#
			# @return [Lenna::Application] Returns the instance.
			#
			# @public
			#
			def app = @app ||= Lenna::Application.new
		end
	end
end
