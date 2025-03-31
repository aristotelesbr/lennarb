module Lennarb
  # Builder for the routes.
  #
  class Routes
    attr_reader :store
    # Builder for the routes.
    #
    # Initializes a new Routes instance with an optional helpers module.
    #
    # @param [Module] helpers_module The module containing helper methods to be included in route blocks (default: an empty Module).
    # @yield [self] Optional block to define routes inline.
    # @return [Routes] The initialized Routes instance.
    # @since 1.0.0
    def initialize(helpers_module = Module.new, &)
      @store = RouteNode.new
      # @!attribute [r] context_module
      # @return [Module] The cached module that includes helpers and provides access to req and res.
      @context_module = Module.new do
        include helpers_module
        attr_accessor :req, :res
      end
      @helpers_module = helpers_module
      instance_eval(&) if block_given?
    end

    # Define the HTTP methods.
    # get, post, put, delete, patch, options, head
    # @return [Array<Symbol>] The HTTP methods.
    # @since 1.0.0
    # @see Lennarb::RouteNode
    HTTP_METHODS.each do |http_method|
      define_method(http_method.downcase) do |path, &block|
        register_route(http_method, path, &block)
      end
    end

    # Define the root route.
    # @param [String] path
    # @param [Proc] block
    # @retrn [void]
    def root(&block) = register_route(:GET, "/", &block)

    # Match the route.
    # @param [Array<String>] parts
    # @param [Symbol] http_method
    def match_route(...) = @store.match_route(...)

    # Freeze store object.
    # @retrn [void]
    def freeze = @store.freeze

    # Define a route for the given HTTP method.
    # @param [Symbol] http_method
    # @param [String] path
    # @param [Proc] block
    # @return [void]
    # @api private
    # @since 1.4.0
    private def register_route(http_method, path, &block)
      parts = path.split("/").reject(&:empty?)
      wrapped_block = wrap_block(&block)
      @store.add_route(parts, http_method, wrapped_block)
    end

    # Wrap the block in a module that includes the helpers.
    # This allows the block to access the request and response objects as well as helper methods.
    # The context module is cached during initialization to improve performance by avoiding
    # repeated module creation per request.
    #
    # @param [Proc] block The route block to be wrapped.
    # @return [Proc] The wrapped block that includes helpers and provides req/res access.
    # @api private
    # @since 1.5.0
    # @example
    #   # Given a helpers_module with `current_user`, the wrapped block can use it:
    #   get "/foo" do |req, res|
    #     res.text("Hello, #{current_user}")
    #   end
    private def wrap_block(&block)
      context_module = @context_module
      proc do |req, res|
        context = Object.new.extend(context_module)
        context.req = req
        context.res = res
        context.instance_exec(req, res, &block)
      end
    end

    # RouteNode is a trie data structure that stores routes.
    # see {Lennarb::RouteNode} for more details.
    module Mixin
      extend self

      # Define the routes.
      # @return [Lennarb::Routes]
      # @see Lennarb::Routes
      def routes(&block)
        @routes ||= Routes.new(&block)
      end

      # Define the HTTP methods.
      # @see Lennarb::Routes#HTTP_METHODS
      # @see Lennarb::Routes#register_route
      # @see Lennarb::Routes#match_route
      HTTP_METHODS.each do |http_method|
        define_method(http_method.downcase) do |path, &block|
          routes.send(http_method.downcase, path, &block)
        end
      end

      # Define the root route.
      # @param [Proc] block.
      # @retrn [void]
      # @see Lennarb::Routes#root
      def root(&) = routes.root(&)
    end
  end
end
