# frozen_string_literal: true

class Lennarb
	class Request < Rack::Request
		# Initialize the request object
		#
		# @parameter [Hash] env
		# @parameter [Hash] route_params
		#
		# @return [Request]
		#
		def initialize(env, route_params = {})
			super(env)
			@route_params = route_params
		end

		# Get the request body
		#
		# @return [String]
		def params
			@params ||= super.merge(@route_params)
		end

		private

		# Get the query string
		#
		# @return [String]
		#
		def query_params
			@query_params ||= Rack::Utils.parse_nested_query(query_string)
		end
	end
end
