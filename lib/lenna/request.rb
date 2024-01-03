# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'uri'

module Lenna
	# The Request class is responsible for managing the request.
	#
	# @public `Since v0.1.0`
	#
	class Request < ::Rack::Request
		# @!attribute [r] headers
		#   @return [Hash] the request headers
		attr_writer :headers

		# @!attribute [r] params
		#   @return [Hash] the request params
		attr_writer :params

		# @!attribute [r] query
		#   @return [Hash] the request query string
		attr_writer :query

		# This method is used to parse the body params.
		#
		# @return [Hash] the request params
		#
		# @public `Since v0.1`
		#
		def params
			@params ||= super.merge(parse_body_params)
		end

		# This method returns the query string.
		#
		# @return [String] the request query string
		#
		# @public `Since v0.1`
		#
		def query
			query_string = env['QUERY_STRING']

			query_params = ::URI.decode_www_form(query_string).to_h

			@query ||= query_params
		rescue ::URI::InvalidURIError
			{}
		end

		# This method rewinds the body
		#
		# @return [String] the request body content
		#
		# @public `Since v0.1`
		#
		def body
			super.rewind
			super.read
		end

		# This method returns the headers in a normalized way.
		#
		# @public `Since v0.1`
		#
		# @return [Hash] the request headers
		#
		# ex.
		#		Turn this:
		#		HTTP_FOO=bar Foo=bar
		#
		def headers
			@headers ||= env.select { |k, _| k.start_with?('HTTP_') }
										.transform_keys { |k| format_header_name(k) }
										.merge(env.select { |k, _| k.start_with?('CONTENT_') }
										.transform_keys { |k| format_header_name(k) })

			@headers
		end

		# This method returns the request body like a json.
		#
		# @return [Hash] the request body
		#
		# @public `Since v0.1`
		#
		def json_body = @json_body ||= parse_body_params

		private

		# This method returns the media type.
		#
		# @return [String] the request media type
		#
		def media_type = headers['Content-Type']

		# This method parses the json body.
		#
		# @return [Hash] the request json body
		#
		def parse_json_body
			@parsed_json_body ||= ::JSON.parse(body)
		rescue ::JSON::ParserError
			{}
		end

		# This method parses the body params.
		#
		# @return [Hash] the request body params
		#
		def parse_body_params
			case media_type
			in 'application/json' then parse_json_body
			else post_params
			end
		end

		# This method parses the post params.
		#
		# @return [Hash] the request post params
		#
		def post_params
			@post_params ||=
				if body.empty?
					{}
				else
					::Rack::Utils.parse_nested_query(body)
				end
		end

		# This method formats the header name.
		#
		# @parameter name [String] the header name
		#
		# @return         [String] the formatted header name
		#
		def format_header_name(name)
			name.sub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')
		end
	end
end
