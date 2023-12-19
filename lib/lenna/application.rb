# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

# Internal dependencies
require 'lenna/middleware/default/error_handler'
require 'lenna/middleware/default/logging'
require 'lenna/router'

module Lenna
	# The base class is used to start the server.
	#
	class Application < Router
		# Initialize the base class
		#
		# @yield { ... } the block to be evaluated in the context of the instance.
		#
		# @return [void | Application] Returns the instance if a block is given.
		#
		def initialize
			super
			yield self if block_given?
		end
	end

	# The base module is used to include the base class.
	#
	module Base
		def self.included(base)
			base.extend(ClassMethods)
		end

		module ClassMethods
			# Initialize the base module
			#
			# @return [Lenna::Application] Returns the instance.
			#
			# @public
			#
			def app = @app ||= Lenna::Application.new
		end
	end
end
