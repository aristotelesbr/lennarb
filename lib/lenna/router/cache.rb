# frozen_string_literal: true

module Lenna
  class Router
    # @api public
    # @note This class is used to cache the routes.
    class Cache
      def initialize = @cache = {}

      # @api public
      # @param [String] method
      # @param [String] path
      # @return [String]
      # @note This method is used to generate a key for the cache.
      def cache_key(method, path) = "#{method} #{path}"

      # @api public
      # @param route_key [String] The key for the route.
      # @param node      [Lenna::Route::Node] The node for the route.
      # @return          [Lenna::Route::Node]
      # @note            This method is used to add a route to the cache.
      def add(route_key, node) = @cache[route_key] = node

      # @api public
      # @param route_key [String] The key for the route.
      # @return          [Lenna::Route::Node]
      # @note            This method is used to get a route from the cache.
      def get(route_key) = @cache[route_key]

      # @api public
      # @param route_key [String] The key for the route.
      # @return          [Boolean]
      # @note            This method is used to check if a route exists
      #                  in the cache.
      def exist?(route_key) = @cache.key?(route_key)
    end
  end
end
