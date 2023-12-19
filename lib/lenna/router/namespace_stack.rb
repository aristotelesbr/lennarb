# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

module Lenna
	class Router
		# This class is used to manage the namespaces.
		#
		# @private `Since v0.1.0`
		#
		class NamespaceStack
			# @return [Array] The stack of namespaces
			#
			# @private
			#
			attr_reader :stack

			# The initialize method is used to initialize the stack of namespaces.
			#
			# @private
			#
			# @attibute stack [Array] The stack of namespaces
			#
			# @return [void]
			#
			def initialize = @stack = ['']

			# This method is used to push a prefix to the stack.
			#
			# @parameter prefix [String] The prefix to be pushed
			#
			# @return           [void]
			#
			# ex.
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
			def current_prefix = @stack.last

			# The to_s method is used to return the current prefix.
			#
			# @return [String] The current prefix
			#
			def to_s = current_prefix

			private

			# The resolve_prefix method is used to resolve the prefix.
			#
			# @parameter prefix [String] The prefix to be resolved
			# @return           [String] The resolved prefix
			#
			def resolve_prefix(prefix)
				current_prefix + prefix
			end
		end
	end
end
