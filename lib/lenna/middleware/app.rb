# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'singleton'

module Lenna
	module Middleware
		# The MiddlewareManager class is responsible for managing the middlewares.
		#
		# @attr global_middlewares      [Array] the global middlewares
		# @attr middleware_chains_cache [Hash]  the middleware chains cache
		#
		# Middleware chains are cached by action.
		# The middlewares that are added to a specific route are added to the
		#   global middlewares.
		#
		# @private Since `v0.1.0`
		#
		class App
			include Singleton

			# @return [Array] the global middlewares.
			#
			attr_accessor :global_middlewares
			# @return [Hash]  the middleware chains cache.
			#
			attr_accessor :middleware_chains_cache

			# This method will initialize the global middlewares and the
			# middleware chains cache.
			#
			# @return [void]
			#
			def initialize
				@global_middlewares = []
				@middleware_chains_cache = {}
			end

			# This method is used to reset the global middlewares and the middleware
			# chains cache.
			#
			# @return [void]
			#
			def reset!
				@global_middlewares = []
				@middleware_chains_cache = {}
			end

			# This method is used to add a middleware to the global middlewares.
			# @parameter middlewares [Array] the middlewares to be used
			# @return                [void]
			#
			def use(middlewares)
				@global_middlewares += Array(middlewares)
				@middleware_chains_cache = {}
			end

			# This method is used to fetch or build the middleware chain for the given
			# action and route middlewares.
			#
			# @parameter action            [Proc]  the action to be executed
			# @parameter route_middlewares [Array] the middlewares to be used
			# @return                      [Proc]  the middleware chain
			#
			#
			def fetch_or_build_middleware_chain(
				action,
				route_middlewares,
				http_method: nil,
				path: nil
			)
				signature =
					if http_method && path
						[http_method, path, route_middlewares].hash.to_s
					else
						['global', route_middlewares].hash.to_s
					end

				@middleware_chains_cache[signature] ||=
					build_middleware_chain(action, route_middlewares)
			end

			# This method is used to build the middleware chain for the given action
			# and middlewares.
			#
			# @parameter action      [Proc]  the action to be executed
			# @parameter middlewares [Array] the middlewares to be used
			# @return                [Proc]  the middleware chain
			#
			# ex.
			#     Given the action:
			#     `->(req, res) { res << 'Hello' }` and the
			#     middlewares [mw1, mw2], the middleware
			#     chain will be:
			#     mw1 -> mw2 -> action
			#     The action will be the last middleware in the
			#     chain.
			#
			def build_middleware_chain(action, middlewares)
				all_middlewares = (@global_middlewares + Array(middlewares))

				all_middlewares.reverse.reduce(action) do |next_middleware, middleware|
					->(req, res) {
						middleware.call(
							req,
							res,
							-> {
								next_middleware.call(req, res)
							}
						)
					}
				end
			end
		end
	end
end
