# frozen_string_literal: true

require 'test_helper'

require 'lenna/middleware/default/reload'

module Lenna
	module Middleware
		module Default
			class TestReload < Minitest::Test
				def test_initialize
					directories = ['test/lib/lenna/middleware/default/test_reload.rb']
					reload      = Lenna::Middleware::Default::Reload.new(directories)

					assert_instance_of(Lenna::Middleware::Default::Reload, reload)
				end

				def test_call
					req = Rack::Request.new({})
					res = Rack::Response.new
					next_middleware = proc { res.status = 200 }
					reload = Lenna::Middleware::Default::Reload.new

					reload.call(req, res, next_middleware)

					assert_equal(200, res.status)
				end
			end
		end
	end
end
