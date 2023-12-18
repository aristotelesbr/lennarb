# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

module Lenna
  class Router
    # This class is used to manage the namespaces.
    #
    # @api private
    #
    # @since 0.1.0
    #
    class NamespaceStack
      # @return [Array] The stack of namespaces
      #
      # @api private
      #
      attr_reader :stack

      # @return [void]
      #
      def initialize = @stack = [""]

      # This method is used to push a prefix to the stack.
      #
      # @param prefix [String] The prefix to be pushed
      #
      # @return       [void]
      #
      # @example:
      #
      #  stack = NamespaceStack.new
      #  stack.push('/users')
      #  stack.current_prefix # => '/users'
      #
      # @see #resolve_prefix
      #
      def push(prefix)
        @stack.push(resolve_prefix(prefix))
      end

      # This method is used to remove the last prefix from the stack.
      #
      # @return [String] The popped prefix
      #
      def pop
        @stack.pop unless @stack.size == 1
      end

      # @return [String] The current prefix
      #
      # @api private
      #
      def current_prefix = @stack.last

      # The to_s method is used to return the current prefix.
      #
      # @return [String] The current prefix
      #
      def to_s = current_prefix

      private

      # The resolve_prefix method is used to resolve the prefix.
      #
      # @param prefix [String] The prefix to be resolved
      # @return       [String] The resolved prefix
      #
      # @see #current_prefix
      #
      def resolve_prefix(prefix)
        current_prefix + prefix
      end
    end
  end
end
