# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

module Lenna
	class Router
		# The Response class is responsible for managing the response.
		#
		# @attr headers [Hash]          the response headers
		# @attr body    [Array(String)] the response body
		# @attr status  [Integer]       the response status
		# @attr params  [Hash]          the response params
		#
		class Response
			# The status of the response.
			#
			# @return [Integer] the status of the Response
			#
			# @public
			#
			public attr_accessor :status

			# The body of the response.
			#
			# @return [Array(String)] the body of the Response
			#
			# @public
			#
			public attr_reader :body

			# The headers of the response.
			#
			# @return [Hash] the headers of the Response
			#
			# @public
			#
			public attr_reader :headers

			# The params of the response.
			#
			# @return [Hash] the params of the Response
			#
			# @public
			#
			public attr_reader :params

			# The length of the response.
			#
			# @return [Integer] the length of the Response
			#
			# @public
			#
			public attr_reader :length

			# This method will initialize the response.
			#
			# @parameter headers [Hash]          the response headers, default is {}
			# @parameter status  [Integer]       the response status, default is 200
			# @parameter body    [Array(String)] the response body, default is []
			# @parameter params  [Hash]          the response params, default is {}
			# @length            [Integer]       the response length, default is 0
			#
			# @return [void]
			#
			def initialize(headers = {}, status = 200, body = [])
				@params = {}
				@body = body
				@status = status
				@headers = headers
				@length = 0
			end

			# This method will set the params.
			#
			# @parameter params [Hash] the params to be used
			#
			# @return           [void]
			#
			# @public
			#
			# ex.
			#   response.params = { 'name' => 'John' }
			#   # => { 'name' => 'John' }
			#
			def assign_params(params)
				params => ::Hash

				@params = params
			rescue ::NoMatchingPatternError
				raise ::ArgumentError, 'params must be a hash'
			end
			alias params= assign_params

			# Returns the response header corresponding to `key`.
			#
			# @parameter key [String] the header name
			#
			# @return        [String] the header value
			#
			# @public
			#
			# ex.
			#     res["Content-Type"]   # => "text/html"
			#     res["Content-Length"] # => "42"
			#
			def [](key) = @headers[key]

			# Thi method set the body value.
			#
			# @parameter value [Array(String)] the body value
			#
			# @return          [void]
			#
			# @public
			#
			def assign_body(value) = put_body(value)
			alias body= assign_body

			# This method will set the header value.
			#
			# @parameter header [String] the header name
			# @parameter value  [String] the header value
			#
			# @return           [void]
			#
			# @public
			#
			# ex.
			#   assign_header('X-Request-Id', '123')
			#   # => '123'
			#
			#   assign_header('X-Request-Id', '456')
			#   # => ['123', '456']
			#
			#   assign_header('X-Request-Id', ['456', '789'])
			#   # => ['123', '456', '789']
			#
			def assign_header(key, value) = put_header(key, value)
			alias []= assign_header

			# Add multiple headers.
			#
			# @parameter headers [Hash] the headers
			# @return            [void]
			#
			# ex.
			#   headers = {
			#     'Content-Type' => 'application/json',
			#     'X-Request-Id' => '123'
			#   }
			#
			def assign_headers(headers)
				headers => ::Hash

				headers.each { |key, value| put_header(key, value) }
			end
			alias headers= assign_headers

			# This method will get the content type.
			#
			# @return [String] the content type
			#
			# @public
			#
			def content_type = @headers['Content-Type']

			# This method will delete the header.
			#
			# @parameter header [String] the header name
			#
			# @return           [void]
			#
			# @public
			#
			def remove_header(key) = delete_header(key)

			# This method will set the cookie.
			#
			# @parameter key   [String] the key of the cookie
			# @return          [void]
			# @parameter value [String] the value of the cookie
			#
			#
			# @public
			#
			# ex.
			#   response.assign_cookie('foo', 'bar')
			#   # => 'foo=bar'
			#
			#   response.header['Set-Cookie']
			#   # => 'foo=bar'
			#
			#  response.assign_cookie('foo2', 'bar2')
			#  # => 'foo=bar; foo2=bar2'
			#  response.header['Set-Cookie']
			#  # => 'foo=bar; foo2=bar2'
			#
			#  response.assign_cookie('bar', {
			#    domain: 'example.com',
			#    path: '/',
			#    # expires: Time.now + 24 * 60 * 60,
			#    secure: true,
			#    httponly: true
			#  })
			#
			# response.header['Set-Cookie'].split('\n').last
			# # => 'bar=; domain=example.com; path=/; secure; HttpOnly'
			#
			# note:
			#  This method doesn't sign and/or encrypt the cookie.
			#  If you want to sign and/or encrypt the cookie, then you can use
			#  the `Rack::Session::Cookie` middleware.
			#
			def assign_cookie(key, value)
				key => ::String
				value => ::String

				::Rack::Utils.set_cookie_header!(@headers, key, value)
			rescue ::NoMatchingPatternError
				raise ::ArgumentError, 'key must be a string'
			end

			# This method will get all the cookies.
			#
			# @return [Hash] the cookies
			#
			# @public
			#
			def cookies = @headers['set-cookie']

			# This method will delete the cookie.
			#
			# @parameter key [String] the key of the cookie
			#
			# @return        [void]
			#
			# @public
			#
			# ex.
			#   response.delete_cookie('foo')
			#   # => 'foo=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000'
			#
			def delete_cookie(key)
				key => ::String

				::Rack::Utils.delete_cookie_header!(@headers, key)
			rescue ::NoMatchingPatternError
				raise ::ArgumentError, 'key must be a string'
			end

			# This method will set redirect location. The status will be set to 302.
			#
			# @parameter location [String] the redirect location
			# @parameter status   [Integer] the redirect status, default is 302.
			#
			# @return             [void]
			#
			# @public
			#
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
			# @public
			#
			def finish = finish!

			# This method will set the response content type.
			#
			# @parameter type    [String] the response content type
			# @parameter charset [Hash]   the response charset
			#
			# @return            [void]
			#
			# @public
			#
			def assign_content_type(type, charset: nil)
				type => ::String

				case charset
				in ::String then put_header('Content-Type', "#{type}; charset=#{charset}")
				else put_header('Content-Type', type)
				end
			rescue ::NoMatchingPatternError
				raise ::ArgumentError, 'type must be a string'
			end

			# This method will set the response data and finish the response.
			#
			# @parameter data [Hash | Array] the response data
			#
			# @return         [void]
			#
			# @public
			#
			# ex.
			#   response.json({ foo: 'bar' })
			#   # => { foo: 'bar' }
			#
			#  response.json([{ foo: 'bar' }])
			#  # => [{ foo: 'bar' }]
			#
			def json(data = {}, status: 200)
				data => ::Array | ::Hash

				put_status(status)
				put_header('Content-Type', 'application/json')
				put_body(data.to_json)

				finish!
			end

			# Set the response content type to text/html.
			#
			# @parameter str [String] the response body
			#
			# @return        [void]
			#
			# @public
			#
			def html(str = nil, status: 200)
				put_status(status)
				put_header('Content-Type', 'text/html')
				put_body(str)

				finish!
			end

			# This method will render the template.
			#
			# @parameter template_nam [String] the template name
			# @parameter path         [String] the template path, default is 'views'
			# @parameter locals       [Hash]   the template locals
			#
			# @return                 [void | Exception]
			#
			# @public
			#
			# ex.
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
			#
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
			# @public
			#
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
			def put_status(value)
				value => ::Integer

				self.status = value
			rescue ::NoMatchingPatternError
				raise ::ArgumentError, 'status must be an integer'
			end

			# This method will set the body.
			#
			# @parameter body [Array(String)] the body to be used
			#
			# @return         [void]
			#
			def put_body(value)
				value => ::String | ::Array

				case value
				in ::String then @body = [value]
				in ::Array  then @body = value
				end
			rescue ::NoMatchingPatternError
				raise ::ArgumentError, 'body must be a string or an array'
			end

			# @parameter key   [String] the header name
			# @parameter value [String] the value to be used
			#
			# @return          [void]
			#
			def put_header(key, value)
				raise ::ArgumentError, 'key must be a string' unless key.is_a?(::String)

				unless value.is_a?(::String) || value.is_a?(::Array)
					raise ::ArgumentError, 'value must be a string or an array'
				end

				header_value = @headers[key]

				new_values = ::Array.wrap(value)
				existing_values = ::Array.wrap(header_value)

				@headers[key] = (existing_values + new_values).uniq.join(', ')
			end

			# This method will delete a header by key.
			#
			# @parameter key [String] the header name
			#
			# @return        [void]
			#
			def delete_header(key) = @headers.delete(key)

			# @parameter value [String] the redirect location
			#
			# @return          [void]
			#
			def location!(value)
				value => ::String

				put_header('Location', value)
			end

			# This method will finish the response.
			#
			# @return [void]
			#
			def finish!
				default_router_header!
				default_content_length! unless @headers['Content-Length']
				default_html_content_type! unless @headers['Content-Type']

				[@status, @headers, @body]
			end

			# This method will set the response default html content type.
			#
			# @return [void]
			#
			def default_html_content_type!
				put_header('Content-Type', 'text/html')
			end

			# This method will set the response default content length.
			#
			# @return [void]
			#
			def default_content_length!
				put_header('Content-Length', @body.join.size.to_s)
			end

			# This method will set the response default router header.
			#
			# @return [void]
			#
			def default_router_header!
				put_header('Server', "Lennarb VERSION #{::Lennarb::VERSION}")
			end
		end
	end
end
