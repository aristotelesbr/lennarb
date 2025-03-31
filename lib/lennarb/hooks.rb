module Lennarb
  # Define hooks for the application.
  # Provides simple before and after hooks that run for all requests.
  #
  module Hooks
    # Called when this module is included in a class
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Add a before hook that runs before each request
      # @param [Proc] block The code to run before handling a request
      # @return [void]
      #
      # @example
      #   before do |req, res|
      #     # Code to run before every request
      #   end
      def before(&block)
        before_hooks << block if block_given?
      end

      # Add an after hook that runs after each request
      # @param [Proc] block The code to run after handling a request
      # @return [void]
      #
      # @example
      #   after do |req, res|
      #     # Code to run after every request
      #   end
      def after(&block)
        after_hooks << block if block_given?
      end

      # Get all before hooks
      # @return [Array<Proc>] All before hooks
      def before_hooks
        @before_hooks ||= []
      end

      # Get all after hooks
      # @return [Array<Proc>] All after hooks
      def after_hooks
        @after_hooks ||= []
      end

      # Execute all before hooks for a request
      # @param [Lennarb::Request] req The request object
      # @param [Lennarb::Response] res The response object
      # @return [void]
      def run_before_hooks(req, res)
        before_hooks.each { |hook| hook.call(req, res) }
      end

      # Execute all after hooks for a request
      # @param [Lennarb::Request] req The request object
      # @param [Lennarb::Response] res The response object
      # @return [void]
      def run_after_hooks(req, res)
        after_hooks.each { |hook| hook.call(req, res) }
      end
    end
  end
end
