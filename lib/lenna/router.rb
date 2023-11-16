# frozen_string_literal: true

# Standard library dependencies
require 'erb'
require 'json'

# External dependencies
require 'rack'

# Internal dependencies
require 'lenna/middleware/app'
require 'lenna/router/builder'
require 'lenna/router/cache'
require 'lenna/router/namespace_stack'
require 'lenna/router/request'
require 'lenna/router/response'
require 'lenna/router/route_matcher'

module Lenna
  # The Node struct is used to represent a node in the tree of routes.
  # @attr children          [Hash]   the children of the node
  # @attr endpoint          [String] the endpoint of the node
  # @attr placeholder_name  [String] the name of the placeholder
  # @attr placeholder       [Bool]   whether the node is a placeholder
  Node =
    ::Struct.new(:children, :endpoint, :placeholder_name, :placeholder) do
      def initialize(children = {}, endpoint = nil, placeholder_name = nil)
        super(children, endpoint, placeholder_name, !placeholder_name.nil?)
      end
    end
  public_constant :Node

  # The router class is responsible for adding routes and calling the
  # middleware chain for each request.
  class Router
    # @return [Node] the root node of the tree of routes
    attr_reader :root_node

    # @return [Route::Cache] the cache of routes
    attr_reader :cache

    # @return [Route::NamespaceStack] the stack of namespaces
    attr_reader :namespace_stack

    # @return [MiddlewareManager] the middleware manager
    attr_reader :middleware_manager

    # @return [Route::Builder] the route builder
    attr_reader :roter_builder

    # @return [void]
    def initialize(middleware_manager: Middleware::App.new, cache: Cache.new)
      @cache     = cache
      @root_node = Node.new({}, nil)
      @middleware_manager = middleware_manager
      @namespace_stack    = NamespaceStack.new
      @roter_builder      = Builder.new(@root_node)
    end

    # This method is used to add a namespace to the routes.
    #
    # @param prefix [String] the prefix to be used
    # @param block  [Proc]   the block to be executed
    # @return       [void]
    # @note                  This method is used to add a namespaces
    #                        to the routes.
    #
    # @since 0.1.0
    #
    # @see Route::NamespaceStack#push
    #
    # @example:
    #
    #   namespace '/api' do |route|
    #     route.get '/users' do
    #       # ...
    #     end
    #   end
    def namespace(prefix, &block)
      @namespace_stack.push(prefix)
      block.call(self)
      @namespace_stack.pop
    end

    # This method is used to add a middleware to the middleware manager.
    #
    # @see MiddlewareManager#use
    #
    # @since 0.1.0
    #
    # @param middlewares [Array] the middlewares to be used
    # @return            [void]
    def use(*middlewares)
      @middleware_manager.use(middlewares)
    end

    # Proxy methods to add routes
    #
    # @see #add_route
    #
    # @since 0.1.0
    #
    # @param path        [String]         the path to be matched
    # @param middlewares [Array]          the middlewares to be used
    # @param action      [Proc]           the action to be executed
    # @return            [Lennarb::Route] the route that was added
    def get(path,    *, &) = add_route(::Rack::GET,    path, *, &)
    def put(path,    *, &) = add_route(::Rack::PUT,    path, *, &)
    def post(path,   *, &) = add_route(::Rack::POST,   path, *, &)
    def delete(path, *, &) = add_route(::Rack::DELETE, path, *, &)

    # @see #call!
    def call(env) = dup.call!(env)

    # This method is used to call the middleware chain for each request.
    #
    # @param env [Hash] the Rack env
    # @return    [Array] the Lennarb::Response
    #
    # @since 0.1.0
    def call!(env)
      # TODO: - Remove this after.
      # env.fetch('RACK_ENV', 'development')
      env['RACK_ENV'] ||= 'development'

      middleware_pipeline = @middleware_manager.fetch_or_build_middleware_chain(
        method(:process_request), []
      )

      req = Request.new(env)
      res = Response.new

      middleware_pipeline.call(req, res)

      res.finish
    end

    private

    # This method is used to add a route to the tree of routes.
    #
    # @see MiddlewareManager#build_middleware_chain
    # @see Route::Cache#add
    # @see Route::Builder#call
    # @see Route::NamespaceStack#current_prefix
    #
    # @since 0.1.0
    #
    # @return            [Lenna::Route] the route that was added
    def add_route(http_method, path, *middlewares, &action)
      full_path = @namespace_stack.current_prefix + path

      middleware_chain = @middleware_manager.build_middleware_chain(
        action,
        middlewares
      )

      @roter_builder.call(http_method, full_path, middleware_chain, @cache)
    end

    # This method is used to process the request.
    #
    # @see Route::Matcher#match_and_execute_route
    #
    # @param req  [Request]  the request
    # @param res  [Response] the response
    # @return     [void]
    def process_request(req, res)
      @route_matcher ||= RouteMatcher.new(@root_node)
      @route_matcher.match_and_execute_route(req, res)
    end
  end
end
