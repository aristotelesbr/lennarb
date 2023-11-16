# frozen_string_literal: true

module Lenna
  module Middleware
    # The MiddlewareManager class is responsible for managing the middlewares.
    #
    # @attr mutex                   [Mutex] the mutex used to synchronize the
    #                                       access to the global middlewares and
    #                                       the middleware chains cache.
    # @attr global_middlewares      [Array] the global middlewares
    # @attr middleware_chains_cache [Hash]  the middleware chains cache
    #
    # @note Middleware chains are cached by action.
    #       The middlewares that are added to a specific route are added to the
    #       global middlewares.
    #
    # @api private
    #
    # @since 0.1.0
    class App
      # @return [Mutex] the mutex used to synchronize the access to the global
      attr_reader :global_middlewares

      # @return [Hash] the middleware chains cache
      attr_reader :middleware_chains_cache

      # This method will initialize the global middlewares and the
      # middleware chains cache.
      #
      # @return [void]
      #
      # @since 0.1.0
      def initialize
        @mutex = ::Mutex.new
        @global_middlewares      = []
        @middleware_chains_cache = {}
      end

      # This method is used to add a middleware to the global middlewares.
      # @param middlewares [Array] the middlewares to be used
      # @return            [void]
      #
      # @since 0.1.0
      def use(middlewares)
        @mutex.synchronize do
          @global_middlewares += Array(middlewares)
          @middleware_chains_cache = {}
        end
      end

      # This method is used to fetch or build the middleware chain for the given
      # action and route middlewares.
      #
      # @param action            [Proc]  the action to be executed
      # @param route_middlewares [Array] the middlewares to be used
      # @return                  [Proc]  the middleware chain
      #
      # @see #build_middleware_chain
      #
      # @since 0.1.0
      def fetch_or_build_middleware_chain(action, route_middlewares)
        middleware_signature = action.object_id.to_s

        @mutex.synchronize do
          @middleware_chains_cache[middleware_signature] ||=
            build_middleware_chain(action, route_middlewares)
        end
      end

      # This method is used to build the middleware chain for the given action
      # and middlewares.
      #
      # @param action      [Proc]  the action to be executed
      # @param middlewares [Array] the middlewares to be used
      # @return            [Proc]  the middleware chain
      #
      # @since 0.1.0
      #
      # @example                   Given the action:
      #                            `->(req, res) { res << 'Hello' }` and the
      #                            middlewares [mw1, mw2], the middleware
      #                            chain will be:
      #                            mw1 -> mw2 -> action
      #                            The action will be the last middleware in the
      #                            chain.
      def build_middleware_chain(action, middlewares)
        all_middlewares = @global_middlewares + Array(middlewares)

        all_middlewares.reverse.reduce(action) do |next_middleware, middleware|
          ->(req, res) {
            middleware.call(
              req,
              res,
              -> {
                next_middleware.call(req, res)
              }
            )
          }
        end
      end
    end
  end
end
