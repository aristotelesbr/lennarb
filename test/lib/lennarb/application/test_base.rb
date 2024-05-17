# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

require 'test_helper'

class Lennarb
	module Application
		class TestBase < Minitest::Test
			include Rack::Test::Methods

			module TestPlugin
				def test_plugin_method = 'Plugin Method Executed'
			end

			Lennarb::Plugin.register(:test_plugin, TestPlugin)

			class MyApp < Lennarb::Application::Base
				plugin :test_plugin

				before do |context|
					context['x-before-hook'] = 'Before Hook'
				end

				after do |context|
					context['x-after-hook'] = 'After Hook'
				end

				get '/' do |_req, res|
					res.status = 200
					res.html('GET Response')
				end

				post '/' do |_req, res|
					res.status = 201
					res.html('POST Response')
				end

				get '/plugin' do |_req, res|
					res.status = 200
					res.html(test_plugin_method)
				end
			end

			def app = MyApp.run!

			def test_get
				get '/'

				assert_predicate last_response, :ok?
				assert_equal 'GET Response', last_response.body
			end

			def test_post
				post '/'

				assert_predicate last_response, :created?
				assert_equal 'POST Response', last_response.body
			end

			def test_before_hooks
				get '/'

				assert_predicate last_response, :ok?
				assert_equal 'Before Hook', last_request.env['x-before-hook']
			end

			def test_after_hooks
				get '/'

				assert_predicate last_response, :ok?
				assert_equal 'After Hook', last_request.env['x-after-hook']
			end

			def test_enviroment
				ENV['LENNARB_ENV'] = 'test'

				assert_predicate MyApp, :test?

				ENV['LENNARB_ENV'] = 'production'

				assert_predicate MyApp, :production?

				ENV['LENNARB_ENV'] = 'development'

				assert_predicate MyApp, :development?
			end

			def test_render_not_found
				get '/not-found'

				assert_predicate last_response, :not_found?
				assert_equal 'Not Found', last_response.body
			end

			def test_plugin_method_execution
				get '/plugin'

				assert_predicate last_response, :ok?
				assert_equal 'Plugin Method Executed', last_response.body
			end

			class MockedMiddleware
				def initialize(app)
					@app = app
				end

				def call(env) = @app.call(env)
			end

			def test_middlewares
				MyApp.use(MockedMiddleware)

				assert_includes MyApp.middlewares, [Lennarb::Application::TestBase::MockedMiddleware, [], nil]
			end
		end
	end
end
