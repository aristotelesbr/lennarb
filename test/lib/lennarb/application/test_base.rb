# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

require 'test_helper'

class Lennarb
	module Application
		class TestBase < Minitest::Test
			include Rack::Test::Methods

			class MyApp < Lennarb::Application::Base
				get '/' do |_req, res|
					res.status = 200
					res.html('GET Response')
				end

				post '/' do |_req, res|
					res.status = 201
					res.html('POST Response')
				end
			end

			def app
				MyApp
			end

			def test_get
				get '/'
				assert last_response.ok?
				assert_equal 'GET Response', last_response.body
			end

			def test_post
				post '/'
				assert last_response.created?
				assert_equal 'POST Response', last_response.body
			end
		end
	end
end
