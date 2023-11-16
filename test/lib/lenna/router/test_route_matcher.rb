# frozen_string_literal: true

require 'test_helper'

module Lenna
  class Router
    class TestRouteMatcher < Minitest::Test
      def test_match_and_execute_route
        root_node = Node.new({}, nil)
        builder   = Builder.new(root_node)
        cache     = Cache.new

        builder.call(
          'GET',
          '/foo',
          ->(_req, res) {
            res.html('Hello, World!')
          },
          cache
        )

        matcher = RouteMatcher.new(root_node)
        env     = Rack::MockRequest.env_for('/foo')

        req = Request.new(env)
        res = Response.new

        matcher.match_and_execute_route(req, res)

        assert_equal 200, res.status
        assert_equal 'text/html', res.headers['Content-Type']
        assert_equal 'Hello, World!', res.body.join
      end

      def test_not_found
        root_node = Node.new({}, nil)
        builder   = Builder.new(root_node)
        cache     = Cache.new

        builder.call(
          'GET',
          '/foo',
          ->(_req, res) {
            res.html('Hello, World!')
          },
          cache
        )

        matcher = RouteMatcher.new(root_node)
        env     = Rack::MockRequest.env_for('/bar')

        req = Request.new(env)
        res = Response.new

        matcher.match_and_execute_route(req, res)

        assert_equal 404, res.status
        assert_equal 'text/html', res.headers['Content-Type']
        assert_equal 'Not Found', res.body.join
      end
    end
  end
end
