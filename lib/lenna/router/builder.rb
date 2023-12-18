# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

module Lenna
  class Router
    # The Route::Builder class is responsible for building the tree of routes.
    #
    # The tree of routes is built by adding routes to the tree. Each route is
    # represented by a node in the tree and each node has a path and an
    # endpoint. The path is the path of the route and the endpoint is then
    # action to be executed when the route is matched.
    #
    # Those nodes are stored in a cache to avoid rebuilding the tree of routes
    # for each request.
    #
    # The tree use `Trie` data structures to optimize the search for a route.
    # The trie is a tree where each node is a character of the path.
    # This way, the search for a route is O(n) where n is the length of the
    # path.
    #
    class Builder
      def initialize(root_node) = @root_node = root_node

      # This method will add a route to the tree of routes.
      #
      # @param method [String] the HTTP method
      # @param path   [String] the path to be matched
      # @param action [Proc]   the action to be executed
      # @param cache  [Cache]  the cache to be used
      #
      # @return       [void]
      #
      def call(method, path, action, cache)
        path_key = cache.cache_key(method, path)

        return if cache.exist?(path_key)

        current_node = find_or_create_route_node(path)
        setup_endpoint(current_node, method, action)

        cache.add(path_key, current_node)
      end

      private

      # This method will create routes that are missing.
      # @param path [String] the path to be matched
      #
      # @return     [Node]   the node that matches the path
      #
      def find_or_create_route_node(path)
        current_node = @root_node
        split_path(path).each do |part|
          current_node = find_or_create_node(current_node, part)
        end
        current_node
      end

      # @param current_node [Node]  the current node
      # @param part         [String] the part of the path
      # @return             [Node]  the node that matches the part of the path
      # @note               This method will create the nodes that are missing.
      #                     This way, the tree of routes is built.
      # @example            Given the part ':id' and the tree bellow:
      #                     root
      #                     └── users
      #                         └── :id
      #                     The method will return the node :id.
      #                     If the node :id does not exist, it will be created.
      #                     The tree will be:
      #                     root
      #                     └── users
      #                         └── :id
      #
      def find_or_create_node(current_node, part)
        if part.start_with?(":")
          # If it is a placeholder, then we just create or update
          # the placeholder node with the placeholder name.
          placeholder_name = part[1..].to_sym
          current_node.children[:placeholder] ||= Node.new(
            {},
            nil,
            placeholder_name
          )
        else
          current_node.children[part] ||= Node.new
        end
        current_node.children[part.start_with?(":") ? :placeholder : part]
      end

      # This method will setup the endpoint of the current node.
      #
      # @param current_node [Node]  the current node
      # @param method       [String] the HTTP method
      # @param action       [Proc]   the action to be executed
      #
      # @return             [void]
      #
      def setup_endpoint(current_node, method, action)
        current_node.endpoint ||= {}
        current_node.endpoint[method] = action
      end

      # This method will split the path into parts.
      #
      # @param path [String] the path to be split
      #
      # @return     [Array]  the splitted path
      #
      # @todo: Move this to a separate file and require it here.
      # Maybe utils or something like that.
      # Use Rack::Utils.split_path_info instead.
      #
      def split_path(path) = path.split("/").reject(&:empty?)
    end
  end
end
