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
        raise "Routes are frozen and cannot be modified" if @frozen
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

    # Freeze the routes to prevent further modification
    #
    # @return [self] The frozen routes
    def freeze
      @frozen = true
      @store.freeze
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
  end
end
