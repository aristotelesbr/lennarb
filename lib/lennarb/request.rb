# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

class Lennarb
	class Request < Rack::Request
		# Initialize the request object
		#
		# @parameter [Hash] env
		# @parameter [Hash] route_params
		#
		# @returns [Request]
		#
		def initialize(env, route_params = {})
			super(env)
			@route_params = route_params
		end

		# Get the request body
		#
		# @returns [String]
		def params
			@params ||= super.merge(@route_params)
		end

		private

		# Get the query string
		#
		# @returns [String]
		#
		def query_params
			@query_params ||= Rack::Utils.parse_nested_query(query_string)
		end
	end
end
