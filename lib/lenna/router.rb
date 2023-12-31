# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'erb'
require 'json'

# External dependencies
require 'rack'

# Internal dependencies
require 'lenna/middleware/app'
require 'lenna/middleware/default/error_handler'
require 'lenna/middleware/default/logging'
require 'lenna/router/builder'
require 'lenna/router/cache'
require 'lenna/router/namespace_stack'
require 'lenna/router/request'
require 'lenna/router/response'
require 'lenna/router/route_matcher'

module Lenna
	# The Node struct is used to represent a node in the tree of routes.
	#
	# @attr children          [Hash]   the children of the node
	# @attr endpoint          [String] the endpoint of the node
	# @attr placeholder_name  [String] the name of the placeholder
	# @attr placeholder       [Bool]   whether the node is a placeholder
	#
	Node =
		::Struct.new(:children, :endpoint, :placeholder_name, :placeholder) do
			def initialize(children = {}, endpoint = nil, placeholder_name = nil)
				super(children, endpoint, placeholder_name, !placeholder_name.nil?)
			end
		end
	public_constant :Node

	# The router class is responsible for adding routes and calling the
	# middleware chain for each request.
	#
	# @private
	#
	class Router
		# @return [Node] the root node of the tree of routes
		#
		attr_reader :root_node

		# @return [Route::Cache] the cache of routes
		#
		attr_reader :cache

		# @return [Route::NamespaceStack] the stack of namespaces
		#
		attr_reader :namespace_stack

		# @return [MiddlewareManager] the middleware manager
		#
		attr_reader :middleware_manager

		# @return [Route::Builder] the route builder
		#
		attr_reader :roter_builder

		# This method is used to initialize the router.
		# By default, it uses the App middleware and the Cache.
		#
		# @return [void]
		#
		def initialize(middleware_manager: Middleware::App.instance, cache: Cache.new)
			@cache = cache
			@root_node = Node.new({}, nil)
			@middleware_manager = middleware_manager
			@namespace_stack = NamespaceStack.new
			@roter_builder = Builder.new(@root_node)
		end

		# This method is used to add a namespace to the routes.
		#
		# @parameter prefix [String] the prefix to be used
		# @parameter block  [Proc]   the block to be executed
		#
		# @return           [void]
		#
		# @public `Since v0.1.0`
		#
		# see {Route::NamespaceStack#push}
		#
		# ex.
		#
		#   namespace '/api' do |route|
		#     route.get '/users' do
		#       # ...
		#     end
		#   end
		#
		def namespace(prefix, &block)
			@namespace_stack.push(prefix)
			block.call(self)
			@namespace_stack.pop
		end

		# This method is used to add a middleware to the middleware manager.
		#
		# See {MiddlewareManager#use}
		#
		# @public `Since v0.1.0`
		#
		#
		# @parameter middlewares [Array] the middlewares to be used
		#
		# @return                [void]
		#
		def use(*middlewares) = @middleware_manager.use(middlewares)

		# Proxy methods to add routes
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
		def get(path, *, &) = add_route(::Rack::GET, path, *, &)
		def put(path, *, &) = add_route(::Rack::PUT, path, *, &)
		def post(path, *, &) = add_route(::Rack::POST, path, *, &)
		def delete(path, *, &) = add_route(::Rack::DELETE, path, *, &)

		def call(env) = dup.call!(env)

		# This method is used to call the middleware chain for each request.
		# It also sets the RACK_ENV to development if it is not set.
		#
		# @parameter env [Hash] the Rack env
		#
		# @return        [Array] the Lennarb::Response
		#
		def call!(env)
			# TODO: Use pifano to set middlewares by environment.
			#
			middlewares_by_enviroment =
				if ENV['RACK_ENV'] == 'development'
					[
						Middleware::Default::Logging,
						Middleware::Default::ErrorHandler
					]
				else
					[]
				end

			middleware_pipeline = @middleware_manager.fetch_or_build_middleware_chain(
				method(:process_request),
				middlewares_by_enviroment
			)

			req = Request.new(env)
			res = Response.new

			middleware_pipeline.call(req, res)

			res.finish
		end

		private

		# This method is used to add a route to the tree of routes.
		#
		# @parameter http_method [Rack::Method] the http method to be used
		# @parameter path        [String]       the path to be matched
		# @parameter middlewares [Array]        the middlewares to be used
		# @parameter action      [Proc]         the action to be executed
		#
		# see {MiddlewareManager#build_middleware_chain}
		# see {Route::Cache#add}
		# see {Route::Builder#call}
		# see {Route::NamespaceStack#current_prefix}
		#
		# @return            [void]
		#
		def add_route(http_method, path, *middlewares, &action)
			full_path = @namespace_stack.current_prefix + path

			middleware_chain = @middleware_manager.fetch_or_build_middleware_chain(action, middlewares, http_method:, path:)

			@roter_builder.call(http_method, full_path, middleware_chain, @cache)
		end

		# This method is used to process the request.
		#
		# It uses the Route::Matcher to match the request to a route and
		# execute the action.
		#
		# @parameter req  [Request]  the request
		# @parameter res  [Response] the response
		#
		# @return         [void]
		#
		def process_request(req, res)
			@route_matcher ||= RouteMatcher.new(@root_node)
			@route_matcher.match_and_execute_route(req, res)
		end
	end
end
