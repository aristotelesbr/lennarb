# frozen_string_literal: true

module Lenna
  class Router
    # This class is used to cache the routes.
    #
    class Cache
      def initialize = @cache = {}

      # This method is used to generate a key for the cache.
      #
      # @api public
      #
      # @param [String] method
      # @param [String] path
      #
      # @return [String]
      #
      def cache_key(method, path) = "#{method} #{path}"

      # This method is used to add a route to the cache.
      #
      # @api public
      #
      # @param route_key [String] The key for the route.
      # @param node      [Lenna::Route::Node] The node for the route.
      #
      # @return          [Lenna::Route::Node]
      #
      def add(route_key, node) = @cache[route_key] = node

      # This method is used to get a route from the cache.
      #
      # @api public
      # @param route_key [String] The key for the route.
      #
      # @return          [Lenna::Route::Node]
      #
      def get(route_key) = @cache[route_key]

      # This method is used to check if a route is in the cache.
      #
      # @api public
      #
      # @param route_key [String] The key for the route.
      #
      # @return          [Boolean]
      #
      def exist?(route_key) = @cache.key?(route_key)
    end
  end
end
