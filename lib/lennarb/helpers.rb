module Lennarb
  # Simple helpers module for Lennarb applications.
  # Provides helper methods to be used in routes and hooks.
  module Helpers
    # Store helpers for app classes
    @app_helpers = {}

    class << self
      # Get the app helpers map
      attr_reader :app_helpers

      # Get helpers module for an app class
      #
      # @param [Class] app_class The application class
      # @return [Module] The helpers module
      def for(app_class)
        app_helpers[app_class] ||= Module.new
      end

      # Define helpers for an app class
      #
      # @param [Class] app_class The application class
      # @param [Proc] block The block with helper definitions
      # @return [Module] The helpers module
      def define(app_class, &block)
        mod = self.for(app_class)
        mod.module_eval(&block) if block_given?
        mod
      end
    end
  end
end
