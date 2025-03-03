module Lennarb
  # Builder for the routes.
  #
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
    # @retrn [void]
    #
    # @example
    #   class MyApp
    #     include Lennarb::Routes::Mixin
    #
    #     root do |req, res|
    #     end
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
    # @retrn [void]
    #
    def freeze = @store.freeze

    private def register_route(http_method, path, &block)
      parts = path.split("/").reject(&:empty?)
      @store.add_route(parts, http_method, block)
    end

    # RouteNode is a trie data structure that stores routes.
    # see {Lennarb::RouteNode} for more details.
    #
    module Mixin
      extend self

      # Define the routes.
      #
      # @return [Lennarb::Routes]
      #
      # @example
      #   class MyApp
      #     include Lennarb::Routes::Mixin
      #
      #     get "/foo" do |req, res|
      #     end
      #   end
      #
      def routes(&block)
        @routes ||= Routes.new(&block)
      end

      # Define the HTTP methods.
      #
      # @see Lennarb::Routes#HTTP_METHODS
      #
      HTTP_METHODS.each do |http_method|
        define_method(http_method.downcase) do |path, &block|
          routes.send(http_method.downcase, path, &block)
        end
      end

      # Define the root route.
      #
      # @param [Proc] block.
      #
      # @retrn [void]
      #
      # @see Lennarb::Routes#root
      #
      def root(&) = routes.root(&)
    end
  end
end
