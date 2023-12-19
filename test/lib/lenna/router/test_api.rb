# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'test_helper'

module Lenna
	class TestBase < ApplicationRequest
		APP =
			Lenna::Application.new do |app|
				app.get('/') do |_request, response|
					response.html('Hello, World!')
				end

				app.get('/hello/:name') do |request, response|
					response.html("Hello, #{request.params[:name]}!")
				end

				app.get('/hello/:name/:age') do |request, response|
					response.html(
						"Hello, #{request.params[:name]}! " \
						"You are #{request.params[:age]} years old."
					)
				end

				app.post('/hello') do |request, response|
					response.html("Hello, #{request.json_body['name']}!")
				end

				default_middleware =
					->(_request, response, next_middleware) {
						response.headers['Default-Origin'] = 'Lenna'
						next_middleware.call
					}

				app.post('/welcome', default_middleware) do |request, response|
					response.html("Welcome #{request.json_body['name']}!")
				end

				app.get('/json') do |_request, response|
					response.json({ foo: 'bar' })
				end
			end
		private_constant :APP

		def app = APP

		def test_get
			get('/')

			assert_predicate last_response, :ok?
			assert_equal 'Hello, World!', last_response.body
		end

		def test_get_with_params
			get('/hello/John')

			assert_predicate last_response, :ok?
			assert_equal 'Hello, John!', last_response.body
		end

		def test_get_with_multiple_params
			get('/hello/John/18')

			assert_predicate last_response, :ok?
			assert_equal 'Hello, John! You are 18 years old.', last_response.body
		end

		def test_post_with_json_body
			post(
				'/hello',
				{ name: 'John' }.to_json,
				'CONTENT_TYPE' => 'application/json'
			)

			assert_predicate last_response, :ok?
			assert_equal 'Hello, John!', last_response.body
		end

		def test_post_with_json_body_and_middleware
			post(
				'/welcome',
				{ name: 'John' }.to_json,
				'CONTENT_TYPE' => 'application/json'
			)

			assert_predicate last_response, :ok?
			assert_equal 'Welcome John!', last_response.body
			assert_equal 'Lenna', last_response.headers['Default-Origin']
		end

		def test_get_json
			get('/json')

			assert_predicate last_response, :ok?
			assert_equal({ foo: 'bar' }.to_json, last_response.body)
		end

		def test_not_found
			get('/not_found')

			assert_predicate last_response, :not_found?
			assert_equal 'Not Found', last_response.body
		end

		def test_default_headers
			get('/')

			headers = last_response.headers

			assert_pattern do
				headers['Content-Type'] => 'text/html'
				headers['Content-Length'] => '13'
				headers['Server'] => "Lennarb VERSION #{Lennarb::VERSION}"
			end
		end
	end
end
