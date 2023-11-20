# frozen_string_literal: true

module Lenna
  class Router
    # The Response class is responsible for managing the response.
    #
    # @attr headers [Hash]          the response headers
    # @attr body    [Array(String)] the response body
    # @attr status  [Integer]       the response status
    # @attr params  [Hash]          the response params
    class Response
      private attr_writer :body, :headers, :status, :params
      public  attr_reader :body, :headers, :status, :params

      def initialize(headers = {}, status = 200, body = [])
        @params  = {}
        @body    = body
        @status  = status
        @headers = headers
      end

      # This method will set the response status.
      #
      # @param value [Integer] the response status
      #
      # @return      [void]
      #
      # @api public
      def assign_status(value) = put_status(value)

      # Thi method set the body value.
      #
      # @param value [Array(String)] the body value
      #
      # @return      [void]
      #
      # @api public
      def assign_body(value) = put_body(value)

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
      #   assign_header('X-Request-Id', '123')
      #   # => '123'
      #
      #   assign_header('X-Request-Id', '456')
      #   # => ['123', '456']
      #
      #   assign_header('X-Request-Id', ['456', '789'])
      #   # => ['123', '456', '789']
      def assign_header(key, value) = put_header(key, value)

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
      #
      def assign_headers(headers)
        headers => ::Hash

        headers.each { |key, value| put_header(key, value) }
      end

      # This method will get the content type.
      #
      # @return [String] the content type
      #
      # @api public
      def content_type = @headers['Content-Type']

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

        @headers['Set-Cookie']
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
      def assign_cookie(key, value)
        key   => ::String
        value => ::String

        cookie = "#{key}=#{value}"

        put_header('Set-Cookie', cookie)
      end

      # This method will get all the cookies.
      #
      # @return [Hash] the cookies
      # @api public
      def cookies
        @headers['Set-Cookie']
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

        put_header('Location', location)
        put_status(status)

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
      def assign_content_type(type, charset: nil)
        type => ::String

        case charset
        in ::String then put_header(
          'Content-Type',
          "#{type}; charset=#{charset}"
        )
        else put_header('Content-Type', type)
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

        put_status(status)
        put_header('Content-Type', 'application/json')
        put_body(data.to_json)

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
        put_status(status)
        put_header('Content-Type', 'text/html')
        put_body(str)

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
        put_body(['Not Found'])
        put_status(404)

        finish!
      end

      private

      # This method will get the response status.
      #
      # @return [Integer] the response status
      #
      # @api private
      def put_status(value)
        value => ::Integer

        self.status = value
      rescue ::NoMatchingPatternError
        raise ::ArgumentError, 'status must be an integer'
      end

      # This method will set the body.
      #
      # @param body [Array(String)] the body to be used
      # @return     [void]
      def put_body(value)
        value => ::String | ::Array

        case value
        in ::String then @body = [value]
        in ::Array  then @body = value
        end
      rescue ::NoMatchingPatternError
        raise ::ArgumentError, 'body must be a string or an array'
      end

      # @param key   [String] the header name
      # @param value [String] the value to be used
      #
      # @return      [void]
      def put_header(key, value)
        key   => ::String
        value => ::String | ::Array

        header_value = @headers[key]

        case value
        in ::String then @headers[key] = [*header_value, value].uniq.join(', ')
        in ::Array  then @headers[key] = [*header_value, *value].uniq.join(', ')
        end
      rescue ::NoMatchingPatternError
        raise ::ArgumentError, 'header must be a string or an array'
      end

      # @param key [String] the header name
      #
      # @return    [void]
      def delete_header(key) = @headers.delete(key)

      # @param value [String] the redirect location
      #
      # @return      [void]
      def location!(value)
        value => ::String

        put_header('Location', value)
      end

      # This method will finish the response.
      #
      # @return [void]
      def finish!
        default_router_header!
        default_content_length!    unless @headers['Content-Length']
        default_html_content_type! unless @headers['Content-Type']

        [@status, @headers, @body]
      end
      
      # This method will set the response default html content type.
      #
      # @return [void]
      def default_html_content_type!
        put_header('Content-Type', 'text/html')
      end

      # This method will set the response default content length.
      #
      # @return [void]
      def default_content_length!
        put_header('Content-Length', @body.join.size.to_s)
      end

      # This method will set the response default router header.
      #
      # @return [void]
      def default_router_header!
        put_header('Server', "Lennarb VERSION #{::Lennarb::VERSION}")
      end
    end
  end
end
