module Lennarb
  class MiddlewareStack
    attr_reader :app

    # The app's middleware stack.
    #
    # @parameter [Rack::Builder] app
    #
    def initialize(app = nil)
      @app = app
      @store = []
    end

    # Insert a middleware in the stack.
    #
    # @parameter [Class] middleware
    # @parameter [Array] args
    # @parameter [Proc] block
    #
    # @returns [void]
    #
    def use(middleware, *args, &block)
      @store << [middleware, args, block]
    end

    # Add a middleware to the beginning of the stack.
    #
    # @parameter [Class] middleware
    # @parameter [Array] args
    # @parameter [Proc] block
    #
    # @returns [void]
    #
    def unshift(middleware, *args, &block)
      @store.unshift([middleware, args, block])
    end

    # Clear the middleware stack.
    #
    # @returns [void]
    #
    def clear
      @store.clear
    end

    # Convert the middleware stack to an array.
    #
    # @returns [Array]
    #
    def to_a
      @store
    end
  end
end
