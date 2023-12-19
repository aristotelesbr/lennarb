# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

module Lenna
	class Router
		# This class is used to cache the routes.
		#
		class Cache
			def initialize = @cache = {}

			# This method is used to generate a key for the cache.
			#
			# @parameter [String] method
			# @parameter [String] path
			#
			# @return [String]
			#
			def cache_key(method, path) = "#{method} #{path}"

			# This method is used to add a route to the cache.
			#
			# @parameter route_key [String] The key for the route.
			# @parameter node      [Lenna::Route::Node] The node for the route.
			#
			# @return              [Lenna::Route::Node]
			#
			def add(route_key, node) = @cache[route_key] = node

			# This method is used to get a route from the cache.
			#
			# @parameter route_key [String] The key for the route.
			#
			# @return              [Lenna::Route::Node]
			#
			def get(route_key) = @cache[route_key]

			# This method is used to check if a route is in the cache.
			#
			# @api public
			#
			# @parameter route_key [String] The key for the route.
			#
			# @return              [Boolean]
			#
			def exist?(route_key) = @cache.key?(route_key)
		end
	end
end
