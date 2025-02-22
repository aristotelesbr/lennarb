module Lennarb
  class Routes
    attr_reader :store
    # RouteNode is a trie data structure that stores routes.
    # see {Lennarb::RouteNode} for more details.
    #
    # @example
    #   node = RouteNode.new
    #   node.add_route(["foo", "bar"], :GET, -> {})
    #
    def initialize(&)
      @store = RouteNode.new
      @constraints = []
      instance_eval(&) if block_given?
    end

    # Define the HTTP methods.
    #
    # get, post, put, delete, patch, options, head
    #
    HTTP_METHODS.each do |http_method|
      define_method(http_method.downcase) do |path, &block|
        register_route(http_method, path, &block)
      end
    end

    # Define the root route.
    #
    # @param [String] path
    #
    # @param [Proc] block
    #
    # @returns [void]
    #
    def root(&block) = register_route(:GET, "/", &block)

    # Match the route.
    #
    # @param [Array<String>] parts
    #
    # @param [Symbol] http_method
    #
    def match_route(...) = @store.match_route(...)

    # Freeze store object.
    #
    # @returns [void]
    #
    def freeze = @store.freeze
 
    private def register_route(http_method, path, &block)
      parts = path.split("/").reject(&:empty?)
      @store.add_route(parts, http_method, block)
    end
  end
end
