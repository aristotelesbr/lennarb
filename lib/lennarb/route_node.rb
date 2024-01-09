# frozen_string_literal: true

class Lennarb
  class RouteNode
    attr_accessor :children, :blocks, :param_key

    # Initialize the route node
    #
    # @return [RouteNode]
    #
    def initialize
      @children  = {}
      @blocks    = {}
      @param_key = nil
    end

    # Add a route to the route node
    #
    # @parameter [Array] parts
    # @parameter [String] http_method
    # @parameter [Proc] block
    #
    # @return [void]
    #
    def add_route(parts, http_method, block)
      current_node = self

      parts.each do |part|
        if part.start_with?(':')
          key = :param
          current_node.children[key] ||= RouteNode.new
          current_node = current_node.children[key]
          current_node.param_key = part[1..].to_sym
        else
          key = part
          current_node.children[key] ||= RouteNode.new
          current_node = current_node.children[key]
        end
      end

      current_node.blocks[http_method] = block
    end

    # Match a route to the route node
    #
    # @parameter [Array] parts
    # @parameter [String] http_method
    #
    # @return [Array]
    #
    def match_route(parts, http_method)
      current_node = self
      params = {}

      parts.each do |part|
        return [nil, nil] unless current_node.children.key?(part) || current_node.children[:param]

        if current_node.children.key?(part)
          current_node = current_node.children[part]
        else
          param_node = current_node.children[:param]
          params[param_node.param_key] = part
          current_node = param_node
        end
      end

      [current_node.blocks[http_method], params]
    end
  end
end
