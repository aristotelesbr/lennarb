# frozen_string_literal: true

require 'test_helper'

module Lenna
  class Router
    class TestRequest < Minitest::Test
      def test_with_query_string
        env = ::Rack::MockRequest.env_for('/?foo=bar')

        assert_equal({ 'foo' => 'bar' }, Request.new(env).params)
      end

      def test_with_headers
        env = ::Rack::MockRequest.env_for('/', 'HTTP_FOO' => 'bar')

        assert_equal({ 'Foo' => 'bar' }, Request.new(env).headers)
      end

      def test_json_body
        env = ::Rack::MockRequest.env_for(
          '/',
          'CONTENT_TYPE' => 'application/json',
          :input => '{"title":"foo","description":"bar"}'
        )
        request = Request.new(env)

        assert_equal 'foo', request.json_body['title']
        assert_equal 'bar', request.json_body['description']
      end

      def test_combined_params
        env = ::Rack::MockRequest.env_for(
          '/?query_param=baz',
          'CONTENT_TYPE' => 'application/json',
          :method => 'POST',
          :input => '{"title":"foo","description":"bar"}'
        )
        request = Request.new(env)

        assert_equal 'baz', request.params['query_param']
        assert_equal 'foo', request.params['title']
        assert_equal 'bar', request.params['description']
      end

      def test_invalid_json_body
        env = ::Rack::MockRequest.env_for(
          '/',
          'CONTENT_TYPE' => 'application/json',
          :input => 'not a json'
        )
        request = Request.new(env)

        assert_empty request.json_body
      end
    end
  end
end
