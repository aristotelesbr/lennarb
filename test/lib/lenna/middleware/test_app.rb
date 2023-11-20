# frozen_string_literal: true

require 'test_helper'

module Lenna
  module Middleware
    class TestApp < Minitest::Test
      def test_use
        manager = App.new
        mdw = ->(_req, _res, next_middleware) { next_middleware.call }
        manager.use(mdw)

        assert_equal manager.global_middlewares, [mdw]
      end

      def test_fetch_or_build_middleware_chain
        manager = App.new
        action = ->(_req, _res) { 'Hello, World!' }
        middleware_chain = manager.fetch_or_build_middleware_chain(action, [])

        assert_equal middleware_chain, action
      end

      def test_middleware_execution_order_and_final_state
        manager  = App.new
        env      = ::Rack::MockRequest.env_for('/')
        request  = Lenna::Router::Request.new(env)
        response = Lenna::Router::Response.new

        mdw1 =
          lambda do |_req, res, next_middleware|
            res.assign_header('Custom-Header', 'From mdw1')
            next_middleware.call
          end
        mdw2 =
          lambda do |_req, res, next_middleware|
            res.assign_header('Custom-Header', 'From mdw2')
            next_middleware.call
          end

        manager.use([mdw1, mdw2])
        action = ->(_req, res) { [200, res.headers, ['OK']] }
        chain = manager.build_middleware_chain(action, [])
        status, headers, body = chain.call(request, response)

        assert_equal(200, status)
        assert_equal({ 'Custom-Header' => 'From mdw1, From mdw2' }, headers)
        assert_equal(['OK'], body)
      end
    end
  end
end
