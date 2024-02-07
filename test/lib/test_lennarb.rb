# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

require 'json'
require 'test_helper'

class TestLennarb < Minitest::Test
	include Rack::Test::Methods

	def test_version
		version = Lennarb::VERSION

		assert_kind_of String, version
	end

	def test_initialize
		app = Lennarb.new

		assert_kind_of Lennarb, app
		assert_respond_to app, :call
	end

	def test_initialize_with_block
		app = Lennarb.new { |route| route.get('/users') { |_req, res| res.text('Hello World!') } }

		assert_kind_of Lennarb, app
		assert_respond_to app, :call
	end

	def test_extends_application_base
		extend Lennarb::ApplicationBase

		assert_respond_to self, :call
		assert_respond_to self, :get
		assert_respond_to self, :post
		assert_respond_to self, :put
		assert_respond_to self, :patch
		assert_respond_to self, :delete
	end

	def app
		Lennarb.new do |route|
			route.get '/users' do |_req, res|
				res[Rack::CONTENT_TYPE] = 'text/html'
				res.status = 200
				res.html('Hello World!')
			end

			route.get '/users/:id' do |req, res|
				id = req.params[:id]

				res[Rack::CONTENT_TYPE] = 'text/plain'
				res.status = 200
				res.text("User #{id}")
			end

			route.post '/users' do |req, res|
				name = req.params['name']
				res[Rack::CONTENT_TYPE] = 'application/json'
				res.status = 201

				res.write({ name: }.to_json)
			end
		end
	end

	def test_get
		get '/users'

		assert_equal 200, last_response.status
		assert_equal 'Hello World!', last_response.body
		assert_equal 'text/html', last_response.headers[Rack::CONTENT_TYPE]
	end

	def test_get_with_paramsf
		get '/users/1'

		assert_equal 200, last_response.status
		assert_equal 'User 1', last_response.body
		assert_equal 'text/plain', last_response.headers[Rack::CONTENT_TYPE]
	end

	def test_post
		post '/users'

		params = { name: 'Aristóteles Coutinho' }
		post '/users', params

		assert_equal 201, last_response.status
		assert_equal params, ::JSON.parse(last_response.body, symbolize_names: true)
		assert_equal 'application/json', last_response.headers[Rack::CONTENT_TYPE]
	end
end
