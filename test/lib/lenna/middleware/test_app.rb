# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'test_helper'

module Lenna
	module Middleware
		class TestApp < Minitest::Test
			def setup
				@app = App.instance
			end

			def test_reset
				mdw =
					lambda do |_req, res, next_middleware|
						res.assign_header('Custom-Header', 'From mdw')
						next_middleware.call
					end

				@app.use(mdw)

				assert_equal @app.global_middlewares, [mdw]
			end

			def test_use
				mdw =
					lambda do |_req, res, next_middleware|
						res.assign_header('Custom-Header', 'From mdw')
						next_middleware.call
					end

				@app.use(mdw)

				assert_equal @app.global_middlewares, [mdw]
			end

			def test_fetch_or_build_middleware_chain
				action = ->(_req, _res, next_middleware) { next_middleware.call }
				middleware_chain = @app.fetch_or_build_middleware_chain(action, [])

				assert_equal middleware_chain, action
			end

			def test_middleware_execution_order_and_final_state
				env = ::Rack::MockRequest.env_for('/')
				request = Lenna::Router::Request.new(env)
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

				@app.use([mdw1, mdw2])
				action = ->(_req, res) { [200, res.headers, ['OK']] }
				chain = @app.build_middleware_chain(action, [])
				status, headers, body = chain.call(request, response)

				assert_equal(200, status)
				assert_equal({ 'Custom-Header' => 'From mdw1, From mdw2' }, headers)
				assert_equal(['OK'], body)
			end
		end
	end
end
