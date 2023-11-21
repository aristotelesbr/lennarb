# frozen_string_literal: true

module Lenna
  class Router
    # The Request class is responsible for managing the request.
    #
    # @attr headers [Hash] the request headers
    # @attr body    [Hash] the request body
    # @attr params  [Hash] the request params
    class Request < ::Rack::Request
      # This method is used to parse the body params.
      #
      # @return [Hash] the request params
      #
      # @api public
      def params = super.merge(parse_body_params)

      # This method rewinds the body
      #
      # @return [String] the request body content
      #
      # @api public
      #
      # @since 0.1.0
      def body_content
        body.rewind
        body.read
      end

      # This method returns the headers in a normalized way.
      #
      # @return [Hash] the request headers
      #
      # @api public
      #
      # @example:
      # Turn this:
      # HTTP_FOO=bar Foo=bar
      def headers
        content_type = env['CONTENT_TYPE']
        @headers ||= env.select { |k, _| k.start_with?('HTTP_') }
                        .transform_keys { |k| format_header_name(k) }
      
        @headers['Content-Type'] = content_type if content_type
        @headers
      end

      # This method returns the request body in a normalized way.
      #
      # @return [Hash] the request body
      #
      # @api public
      def json_body = @json_body ||= parse_body_params

      private

      def json_request? = media_type == 'application/json'

      def parse_json_body
        @parsed_json_body ||= ::JSON.parse(body_content) if json_request?
      rescue ::JSON::ParserError
        {}
      end

      def parse_body_params
        case media_type
        when 'application/json'
          parse_json_body
        when 'application/x-www-form-urlencoded', 'multipart/form-data'
          post_params
        else
          {}
        end
      end

      def format_header_name(name)
        name.sub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')
      end
    end
  end
end
