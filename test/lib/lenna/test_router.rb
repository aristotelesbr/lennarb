# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require "test_helper"

module Lenna
  class Router
    class TestRouter < Minitest::Test
      def test_initialize
        router = Router.new

        assert_kind_of Node, router.root_node
        assert_kind_of Cache, router.cache
        assert_kind_of Builder, router.roter_builder
        assert_kind_of NamespaceStack, router.namespace_stack
        assert_kind_of Middleware::App, router.middleware_manager
      end

      def test_add_namespace
        router = Router.new
        router.namespace("/foo") do |route|
          route.get("/bar") { |_req, res| res.html("Hello, World!") }
        end

        env = ::Rack::MockRequest.env_for("/foo/bar")

        status, headers, body = router.call(env)

        assert_equal 200, status
        assert_equal "text/html", headers["Content-Type"]
        assert_equal "Hello, World!", body.join
      end

      def test_call
        router = Router.new
        router.get("/foo") { |_req, res| res.html("Hello, World!") }

        env = ::Rack::MockRequest.env_for("/foo")

        status, headers, body = router.call(env)

        assert_equal 200, status
        assert_equal "text/html", headers["Content-Type"]
        assert_equal "Hello, World!", body.join
      end

      def test_call_with_middleware
        router = Router.new

        timex = ::Time.now.to_s

        simple_middleware =
          ->(_req, res, next_middleware) {
            res.headers["X-Time"] = timex
            next_middleware.call
          }

        router.use(simple_middleware)

        router.get("/foo") { |_req, res| res.html("Hello, World!") }

        env = ::Rack::MockRequest.env_for("/foo")

        status, headers, body = router.call(env)

        assert_equal 200, status
        assert_equal timex, headers["X-Time"]
        assert_equal "Hello, World!", body.join
      end

      def test_call_with_middleware_in_route
        router = Router.new

        timex = ::Time.now.to_s

        simple_middleware =
          ->(_req, res, next_middleware) {
            res.headers["X-Time"] = timex
            next_middleware.call
          }

        router.get("/foo", simple_middleware) do |_req, res|
          res.html("Hello, World!")
        end

        env = ::Rack::MockRequest.env_for("/foo")

        status, headers, body = router.call(env)

        assert_equal 200, status
        assert_equal timex, headers["X-Time"]
        assert_equal "Hello, World!", body.join
      end
    end
  end
end
