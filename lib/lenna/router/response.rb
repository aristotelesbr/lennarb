# frozen_string_literal: true

module Lenna
  class Router
    # The Response class is responsible for managing the response.
    #
    # @attr _headers [Hash]          the response headers
    # @attr _body    [Array(String)] the response body
    # @attr _status  [Integer]       the response status
    # @attr params   [Hash]          the response params
    class Response
      public  attr_reader :params
      private attr_accessor :_headers, :_body, :_status

      def initialize(headers = {}, status = 200, body = [])
        self._headers = headers
        self._status  = status
        self._body    = body
        @params       = {}
      end

      # @api public
      #
      # @return [Integer] the response status
      def status = fetch_status

      # @api public
      #
      # @param status [Integer] the response status
      #
      # @return       [void]
      def put_status(value) = status!(value)

      # @api public
      #
      # @return [Array(String)] the body value
      def body = fetch_body

      # @api public
      #
      # @param value [Array(String)] the body value
      #
      # @return      [void]
      def put_body(value) = body!(value)


      # This method will get the header value.
      #
      # @api public
      #
      # @param header [String] the header name
      #
      # @return       [String] the header value
      def header(key) = fetch_header(key)

      # @api public
      #
      # @return [Hash] the response headers
      def headers = fetch_headers

      # This method will set the header value.
      #
      # @param header [String] the header name
      # @param value  [String] the header value
      # @return       [void]
      # @note                  This method will set the header value.
      #                        If the header already exists, then the value will
      #                        be appended to the header.
      #
      # @api public
      #
      # @example
      #   put_header('X-Request-Id', '123')
      #   # => '123'
      #
      #   put_header('X-Request-Id', '456')
      #   # => ['123', '456']
      #
      #   put_header('X-Request-Id', ['456', '789'])
      #   # => ['123', '456', '789']
      def put_header(key, value) = header!(key, value)

      # Add multiple headers.
      #
      # @param headers [Hash] the headers
      # @return        [void]
      # @note                 This method will add the headers.
      #                       The headers are a hash where the key is the
      #                       header name and the value is the header value.
      #
      # @example
      #   headers = {
      #     'Content-Type' => 'application/json',
      #     'X-Request-Id' => '123'
      #   }
      def put_headers(headers)
        headers => ::Hash

        headers.each { |key, value| put_header(key, value) }
      end

      # This method will get the content type.
      #
      # @return [String] the content type
      #
      # @api public
      def content_type = header('Content-Type')

      # This method will delete the header.
      # @param header [String] the header name
      #
      # @return       [void]
      #
      # @api public
      def remove_header(key) = delete_header(key)

      # This method will get the redirect location.
      #
      # @param value [String] the key of the cookie
      #
      # @return      [String] the cookie
      #
      # @api public
      def cookie(value)
        value => ::String

        fetch_header('Set-Cookie')
          .then { |cookie| cookie.split('; ') }
          .then { |cookie| cookie.find { |c| c.start_with?("#{value}=") } }
          .then { |cookie| cookie.split('=').last }
      end

      # This method will set the cookie.
      #
      # @param key   [String] the key of the cookie
      # @param value [String] the value of the cookie
      #
      # @return      [void]
      #
      # @api public
      def put_cookie(key, value)
        key   => ::String
        value => ::String

        cookie = "#{key}=#{value}"

        header!('Set-Cookie', cookie)
      end

      # This method will get all the cookies.
      #
      # @return [Hash] the cookies
      # @api public
      def cookies
        fetch_header('Set-Cookie')
          .then { |cookie| cookie.split('; ') }
          .each_with_object({}) do |cookie, acc|
          key, value = cookie.split('=')

          acc[key] = value
        end
      end

      # This method will set redirect location. The status will be set to 302.
      #
      # @param location [String] the redirect location
      # @param status   [Integer] the redirect status, default is 302.
      #
      # @return         [void]
      #
      # @api public
      def redirect(location, status: 302)
        location => ::String

        header!('Location', location)
        status!(status)

        finish!
      rescue ::NoMatchingPatternError
        raise ::ArgumentError, 'location must be a string'
      end

      # This method will finish the response.
      #
      # @return [void]
      #
      # @api public
      def finish = finish!

      # This method will set the response content type.
      #
      # @param type    [String] the response content type
      # @param charset [Hash]   the response charset
      #
      # @return        [void]
      #
      # @api public
      def put_content_type(type, charset: nil)
        type => ::String

        case charset
        in ::String then header!('Content-Type', "#{type}; charset=#{charset}")
        else             header!('Content-Type', type)
        end
      rescue ::NoMatchingPatternError
        raise ::ArgumentError, 'type must be a string'
      end

      # This method will set the response data and finish the response.
      #
      # @param data [Hash, Array] the response data
      #
      # @return     [void]
      #
      # @api public
      def json(data:, status: 200)
        data => ::Array | ::Hash

        status!(status)
        header!('Content-Type', 'application/json')
        body!(data.to_json)

        finish!
      end

      # Set the response content type to text/html.
      #
      # @param str [String] the response body
      #
      # @return    [void]
      #
      # @api public
      def html(str = nil, status: 200)
        status!(status)
        header!('Content-Type', 'text/html')
        body!(str)

        finish!
      end

      # This method will render the template.
      #
      # @param template_nam [String] the template name
      # @param path         [String] the template path, default is 'views'
      # @param locals       [Hash]   the template locals
      #
      # @return             [void | Exception]
      #
      # @example
      #   render('index')
      #   # => Render the template `views/index.html.erb`
      #
      #   render('users/index')
      #   # => Render the template `views/users/index.html.erb`
      #
      #   render('index', path: 'app/views/users')
      #   # => Render the template `app/views/users/index.html.erb`
      #
      #   render('index', locals: { name: 'John' })
      #   # => Render the template `views/index.html.erb` with the local
      #   #    variable `name` set to 'John'
      def render(template_name, path: 'views', locals: {}, status: 200)
        template_path = ::File.join(path, "#{template_name}.html.erb")

        # Check if the template exists
        unless File.exist?(template_path)
          msg = "Template not found: #{template_path} 🤷‍♂️."

          # Oops! The template doesn't exist or the path is wrong.
          #
          # The template exists? 🤔
          # If you want to render a template from a custom path, then you
          # can pass the full path though the path: keyword argument instead
          # of just the name. For example:
          # render('index', path: 'app/views/users')
          raise msg
        end

        ::File
          .read(template_path)
          .then { |template| ::ERB.new(template).result_with_hash(locals) }
          .then { |erb_template| html(erb_template, status:) }
      end

      # Helper methods for the response.
      #
      # @return [void]
      #
      # @api public
      #
      # @see #render
      # @see #finish!
      def not_found
        body!(['Not Found'])
        status!(404)
        finish!
      end

      private

      # This method will get the response status.
      #
      # @return [Integer] the response status
      #
      # @api private
      def fetch_status = _status

      # This method will get the response status.
      #
      # @return [Integer] the response status
      #
      # @api private
      def status!(value)
        value => ::Integer

        self._status = value
      rescue ::NoMatchingPatternError
        raise ::ArgumentError, 'status must be an integer'
      end

      # @return [Array(String)] the body value
      def fetch_body = _body

      # This method will set the body.
      #
      # @param body [Array(String)] the body to be used
      # @return     [void]
      def body!(value)
        body => ::String | ::Array

        case value
        in ::String then self._body = [value]
        in ::Array  then self._body = value
        end
      rescue ::NoMatchingPatternError
        raise ::ArgumentError, 'body must be a string or an array'
      end

      # @param header [String] the header name
      #
      # @return       [String] the header value
      def fetch_header(header) = _headers[header]

      # @return [Hash] the response headers
      def fetch_headers = _headers

      # @param key   [String] the header name
      # @param value [String] the value to be used
      #
      # @return      [void]
      def header!(key, value)
        key   => ::String
        value => ::String | ::Array

        header_value = fetch_header(key)

        case value
        in ::String then _headers[key] = [*header_value, value].uniq.join(', ')
        in ::Array  then _headers[key] = [*header_value, *value].uniq.join(', ')
        end
      rescue ::NoMatchingPatternError
        raise ::ArgumentError, 'header must be a string or an array'
      end

      # @param key [String] the header name
      #
      # @return    [void]
      def delete_header(key) = _headers.delete(key)

      # @param value [String] the redirect location
      #
      # @return      [void]
      def location!(value)
        value => ::String

        header!('Location', value)
      end

      # @param value [String] the content value
      #
      # @return      [String] the size of the content
      def content_length!(value) = header!('Content-Length', value)

      # This method will finish the response.
      #
      # @return [void]
      def finish!
        put_content_type('text/html')        unless header('Content-Type')
        content_length!(body.join.size.to_s) unless header('Content-Length')

        [_status, _headers, _body]
      end
    end
  end
end
