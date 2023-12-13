# frozen_string_literal: true

module Lenna
  class Router
    # The Request class is responsible for managing the request.
    #
    # @attr headers [Hash] the request headers
    # @attr body    [Hash] the request body
    # @attr params  [Hash] the request params
    #
    class Request < ::Rack::Request
      # This method is used to set the request headers.
      #
      # @param name  [String] the header name
      # @param value [String] the header value
      #
      # @return [String] the header value
      #
      # @api public
      #
      # @example:
      #   request.put_header('Foo', 'bar')
      #
      #  request.headers
      #  # => { 'Foo' => 'bar' }
      #
      def put_header(name, value) = headers[name] = value

      # This method is used to set the request params.
      #
      # @param params [Hash] the request params
      #
      # @return [Hash] the request params
      #
      # @api public
      #
      def assign_params(params) = @params = params

      # This method is used to parse the body params.
      #
      # @return [Hash] the request params
      #
      # @api public
      #
      def params = super.merge(parse_body_params)

      # This method rewinds the body
      #
      # @return [String] the request body content
      #
      # @api public
      #
      # @since 0.1.0
      #
      def body
        super.rewind
        super.read
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
      #
      def headers
        content_type = env['CONTENT_TYPE']
        @headers ||= env.select { |k, _| k.start_with?('HTTP_') }
                        .transform_keys { |k| format_header_name(k) }

        @headers['Content-Type'] = content_type if content_type
        @headers
      end

      # This method returns the request body like a json.
      #
      # @return [Hash] the request body
      #
      # @api public
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
      # @api private
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
      # @api private
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
      # @api private
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
      # @param name [String] the header name
      #
      # @return [String] the formatted header name
      #
      # @api private
      #
      def format_header_name(name)
        name.sub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')
      end
    end
  end
end
