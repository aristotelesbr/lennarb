# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

require 'test_helper'

class Lennarb
	class TestApplicationCore < Minitest::Test
		class MyApp
			include Lennarb::ApplicationCore

			route.get '/' do |_req, res|
				res.status = 200
				res.html('GET Response')
			end

			route.post '/' do |_req, res|
				res.status = 201
				res.html('POST Response')
			end
		end

		def test_included
			assert_respond_to MyApp, :route
			assert_respond_to MyApp, :app
			assert_respond_to MyApp, :before
			assert_respond_to MyApp, :after
			assert_respond_to MyApp, :plug
		end

		def test_ancestors
			assert_includes MyApp.ancestors, Lennarb::ApplicationCore
		end

		def test_router
			assert_kind_of Lennarb, MyApp.route
		end
	end

	def test_route
		app = Rack::Test::Session.new(app)

		app.get '/'

		assert_equal 200, app.last_response.status
		assert_equal 'GET Response', app.last_response.body
		assert_equal 'text/html', app.last_response.headers[Rack::CONTENT_TYPE]
	end

	def test_route_post
		app = Rack::Test::Session.new(app)

		app.post '/'

		assert_equal 201, app.last_response.status
		assert_equal 'POST Response', app.last_response.body
		assert_equal 'text/html', app.last_response.headers[Rack::CONTENT_TYPE]
	end
end
