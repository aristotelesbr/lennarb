module Lennarb
  # Basic middleware stack implementation.
  #
  class MiddlewareStack
    attr_reader :app

    # The app's middleware stack.
    #
    # @param [Rack::Builder] app
    #
    def initialize(app = nil)
      @app = app
      @store = []
    end

    # Insert a middleware in the stack.
    #
    # @param [Class] middleware
    # @param [Array] args
    # @param [Proc] block
    #
    # @retrn [void]
    #
    def use(middleware, *args, &block)
      @store << [middleware, args, block]
    end

    # Add a middleware to the beginning of the stack.
    #
    # @param [Class] middleware
    # @param [Array] args
    # @param [Proc] block
    #
    # @retrn [void]
    #
    def unshift(middleware, *args, &block)
      @store.unshift([middleware, args, block])
    end

    # Clear the middleware stack.
    #
    # @retrn [void]
    #
    def clear
      @store.clear
    end

    # Convert the middleware stack to an array.
    #
    # @retrn [Array]
    #
    def to_a
      @store
    end
  end
end
