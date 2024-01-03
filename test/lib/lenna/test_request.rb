# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'test_helper'

module Lenna
	class TestRequest < Minitest::Test
		def test_params_form_urlencoded
			env = ::Rack::MockRequest.env_for(
				'/',
				'CONTENT_TYPE' => 'application/x-www-form-urlencoded',
				method: 'POST',
				:input => 'title=foo&description=bar'
			)
			request = Request.new(env)

			assert_equal 'foo', request.params['title']
			assert_equal 'bar', request.params['description']
		end

		def test_params_json
			env = ::Rack::MockRequest.env_for(
				'/',
				'CONTENT_TYPE' => 'application/json',
				method: 'POST',
				:input => '{"title":"foo","description":"bar"}'
			)
			request = Request.new(env)

			assert_equal 'foo', request.params['title']
			assert_equal 'bar', request.params['description']
		end

		def test_query_string
			env = ::Rack::MockRequest.env_for('/?foo=bar', method: 'GET')

			assert_equal({ 'foo' => 'bar' }, Request.new(env).query)
		end

		def test_headers
			env = ::Rack::MockRequest.env_for('/', 'HTTP_FOO' => 'bar')

			assert_equal({ 'Foo' => 'bar', 'Content-Length' => '0' }, Request.new(env).headers)
		end

		def test_json_body
			env = ::Rack::MockRequest.env_for(
				'/',
				'CONTENT_TYPE' => 'application/json',
				method: 'POST',
				:input => '{"title":"foo","description":"bar"}'
			)
			request = Request.new(env)

			assert_equal 'foo', request.json_body['title']
			assert_equal 'bar', request.json_body['description']
		end

		def test_invalid_json_body
			env = ::Rack::MockRequest.env_for(
				'/',
				'CONTENT_TYPE' => 'application/json',
				method: 'POST',
				:input => 'not a json'
			)
			request = Request.new(env)

			assert_empty request.json_body
		end

		def test_body_params
			env = ::Rack::MockRequest.env_for(
				'/',
				'CONTENT_TYPE' => 'application/x-www-form-urlencoded',
				method: 'POST',
				:input => 'title=foo&description=bar'
			)
			request = Request.new(env)

			assert_equal 'foo', request.params['title']
			assert_equal 'bar', request.params['description']
		end

		def test_headers=
			env = ::Rack::MockRequest.env_for('/', 'HTTP_FOO' => 'bar')
			request = Request.new(env)

			request.headers['Foo'] = 'baz'
			request.headers['Bar'] = 'bar'

			assert_equal({ 'Foo' => 'baz', 'Content-Length' => '0', 'Bar' => 'bar' }, request.headers)
		end
	end
end
