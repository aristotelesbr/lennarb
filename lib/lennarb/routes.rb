module Lennarb
  # Routes class for managing application routes
  #
  class Routes
    # Initialize a new Routes instance
    #
    # @return [Routes] The initialized routes instance
    def initialize
      @store = RouteNode.new
      @frozen = false
    end

    # Define a route for each HTTP method
    HTTP_METHODS.each do |http_method|
      define_method(http_method.downcase) do |path, &block|
        fail RoutesFrozenError, "Routes are frozen and cannot be modified" if @frozen
        register_route(http_method, path, &block)
      end
    end

    # Define the root route (GET /)
    #
    # @param block [Proc] Block to execute when route matches
    # @return [void]
    def root(&block)
      get("/", &block)
    end

    # Match a route with the given path parts and HTTP method
    #
    # @param parts [Array<String>] Path parts
    # @param http_method [Symbol] HTTP method
    # @return [Array(Proc, Hash), nil] Route handler and params, or nil if no match
    def match_route(parts, http_method)
      @store.match_route(parts, http_method)
    end

    # Copy the routes from another Routes instance into this one.
    #
    # The copy is deep: node objects are rebuilt rather than shared, so routes
    # registered on the source afterwards cannot leak into this instance.
    #
    # @param other [Routes] The routes to copy from
    # @return [self]
    # @api private
    def merge!(other)
      @store.merge!(deep_copy(other.store))
      self
    end

    # Freeze the routes to prevent further modification.
    #
    # Freezes the whole tree, not only the root, so a frozen copy really is
    # immutable.
    #
    # @return [self] The frozen routes
    def freeze
      @frozen = true
      deep_freeze(@store)
      self
    end

    # Check if the routes are frozen
    #
    # @return [Boolean] True if frozen
    def frozen?
      @frozen
    end

    private

    # Register a route with the specified HTTP method and path
    #
    # @param http_method [Symbol] HTTP method (:GET, :POST, etc.)
    # @param path [String] Route path pattern
    # @param block [Proc] Block to execute when route matches
    # @return [void]
    def register_route(http_method, path, &block)
      parts = path.split("/").reject(&:empty?)
      @store.add_route(parts, http_method, block)
    end

    # The underlying route tree.
    #
    # Protected so that merge! can reach a sibling instance's store without
    # exposing the tree publicly.
    #
    # @return [RouteNode]
    # @api private
    protected def store
      @store
    end

    # Rebuild a route tree, sharing no node objects with the original.
    #
    # @param node [RouteNode] The node to copy
    # @return [RouteNode] The copy
    def deep_copy(node)
      copy = RouteNode.new
      copy.param_key = node.param_key
      copy.blocks = node.blocks.dup

      node.static_children.each { |part, child| copy.static_children[part] = deep_copy(child) }
      node.dynamic_children.each { |param, child| copy.dynamic_children[param] = deep_copy(child) }

      copy
    end

    # Freeze a route tree from the leaves up.
    #
    # @param node [RouteNode] The node to freeze
    # @return [RouteNode] The frozen node
    def deep_freeze(node)
      node.static_children.each_value { deep_freeze(it) }
      node.dynamic_children.each_value { deep_freeze(it) }
      node.freeze
    end
  end
end
