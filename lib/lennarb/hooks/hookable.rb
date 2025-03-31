module Lennarb
  class Hooks
    # The Hookable module provides a mechanism to add hooks to classes.
    # It allows defining `before` and `after` hooks that can be executed
    # around certain operations.
    # @since 1.5.0
    module Hookable
      # Extends the base class with class methods when the module is included.
      #
      # @param base [Class] the class that includes the Hookable module
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Class methods for managing hooks.
      module ClassMethods
        # Returns the hook handler instance, initializing it if necessary.
        #
        # @return [Hooks] the hook handler instance
        def hook_handler
          @hook_handler ||= Hooks.new(helpers_module)
        end

        # Registers a block to be executed before the main operation.
        #
        # @yield the block to be executed before
        def before(&block)
          hook_handler.before(&block)
        end

        # Registers a block to be executed after the main operation.
        #
        # @yield the block to be executed after
        def after(&block)
          hook_handler.after(&block)
        end
      end
    end
  end
end
