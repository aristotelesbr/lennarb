module Lennarb
  # Provides hook functionality for Lennarb applications.
  # Hooks execute code before and after route handlers.
  #
  # @example
  #   Hooks.add(MyApp, :before) do |req, res|
  #     res.headers["X-My-Header"] = "MyValue"
  #   end
  #   Hooks.add(MyApp, :after) do |req, res|
  #     res.body << "Goodbye!"
  #   end
  #
  # @note
  #   - Hooks are executed in the order they are added.
  #   - The context of the hook is the object that calls the route handler.
  #   - Hooks can modify the request and response objects.
  #   - Hooks can be used to implement middleware-like functionality.
  #   - Hooks are not thread-safe. Use with caution in multi-threaded environments.
  module Hooks
    # Valid hook types
    TYPES = [:before, :after].freeze

    # Store hooks for each app class
    @app_hooks = {}

    class << self
      # Get the hooks hash
      #
      # @return [Hash] The hooks hash with app classes as keys
      attr_reader :app_hooks

      # Get the hooks for an app class
      #
      # @param [Class] app_class The application class
      # @return [Hash] The hooks hash with :before and :after keys
      def for(app_class)
        app_hooks[app_class] ||= {before: [], after: []}
      end

      # Add a hook for an app class
      #
      # @param [Class] app_class The application class
      # @param [Symbol] type The hook type (:before or :after)
      # @param [Proc] block The hook block
      # @return [Array] The hooks array for the given type
      def add(app_class, type, &block)
        raise ArgumentError, "Invalid hook type: #{type}" unless TYPES.include?(type)

        hooks = self.for(app_class)
        hooks[type] << block if block_given?
        hooks[type]
      end

      # Execute hooks of a given type
      #
      # @param [Object] context The execution context
      # @param [Class] app_class The application class
      # @param [Symbol] type The hook type to execute
      # @param [Request] req The request object
      # @param [Response] res The response object
      # @return [void]
      def execute(context, app_class, type, req, res)
        hooks = self.for(app_class)[type]

        hooks.each do |hook|
          context.instance_exec(req, res, &hook)
        end
      end
    end
  end
end
