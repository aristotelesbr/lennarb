# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

class Lennarb
	# This module must be included in the class that will use the router.
	#
	module Router
		def self.included(base)
			base.extend(ClassMethods)
			base.instance_variable_set(:@router, Lennarb.new)
			base.define_singleton_method(:router) do
				base.instance_variable_get(:@router)
			end
		end

		module ClassMethods
			# Helper method to define a route
			#
			# returns [Lennarb] instance of the router
			#
			def route = router

			# Use this in congi.ru to start the application
			#
			def app
				router.freeze!
				router
			end
		end
	end
end
