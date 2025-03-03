module Lennarb
  # RouteNode is key to the routing system. It is a tree structure that
  # represents the routes of the application.
  #
  # @example
  #   node = RouteNode.new
  #   node.add_route(["foo", "bar"], :GET, -> {})
  #
  # @note RouteNode use a trie data structure to store the routes and match them.
  #
  class RouteNode
    attr_accessor :static_children, :dynamic_children, :blocks, :param_key

    # Initialize the route node.
    #
    # @retrn [RouteNode]
    #
    def initialize
      @blocks = {}
      @param_key = nil
      @static_children = {}
      @dynamic_children = {}
    end

    # Add a route to the route node.
    #
    # @param parts [Array<String>] The parts of the route.
    # @param http_method [String] The HTTP method.
    # @param block [Proc] The block to be executed when the route is matched.
    #
    # @retrn [void]
    #
    def add_route(parts, http_method, block)
      current_node = self

      parts.each do |part|
        if part.start_with?(":")
          param_sym = part[1..].to_sym
          current_node.dynamic_children[param_sym] ||= RouteNode.new
          dynamic_node = current_node.dynamic_children[param_sym]
          dynamic_node.param_key = param_sym
          current_node = dynamic_node
        else
          current_node.static_children[part] ||= RouteNode.new
          current_node = current_node.static_children[part]
        end
      end

      current_node.blocks[http_method] = block
    end

    # Match a route.
    #
    # @param parts [Array<String>] The parts of the route.
    # @param http_method [String] The HTTP method.
    # @param params [Hash] The parameters of the route.
    #
    # @retrn [Array<Proc, Hash>]
    #
    def match_route(parts, http_method, params: {})
      if parts.empty?
        return [blocks[http_method], params] if blocks[http_method]
      else
        part = parts.first
        rest = parts[1..]

        if static_children.key?(part)
          result_block, result_params = static_children[part].match_route(rest, http_method, params:)
          return [result_block, result_params] if result_block
        end

        dynamic_children.each_value do |dyn_node|
          new_params = params.dup
          new_params[dyn_node.param_key] = part
          result_block, result_params = dyn_node.match_route(rest, http_method, params: new_params)

          return [result_block, result_params] if result_block
        end
      end

      [nil, nil]
    end

    # Merge another route node into this one.
    #
    # @param other [RouteNode] The other route node.
    #
    # @retrn [void|DuplicateRouteError]
    #
    def merge!(other)
      other.blocks.each do |http_method, block|
        if @blocks[http_method]
          raise Lennarb::DuplicateRouteError, "Duplicate route for HTTP method: #{http_method}"
        end
        @blocks[http_method] = block
      end

      other.static_children.each do |path, node|
        if @static_children[path]
          @static_children[path].merge!(node)
        else
          @static_children[path] = node
        end
      end

      other.dynamic_children.each do |param, node|
        if @dynamic_children[param]
          @dynamic_children[param].merge!(node)
        else
          @dynamic_children[param] = node
        end
      end
    end
  end
end
