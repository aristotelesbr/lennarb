# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

require 'test_helper'
require 'json'

class Lennarb
	module Application
		class TestBase < Minitest::Test
			include Rack::Test::Methods

			module TestPlugin
				module InstanceMethods
					def test_plugin_method = 'Plugin Method Executed'
				end

				module ClassMethods
					def test_plugin_class_method = 'Plugin Class Method Executed'
				end

				def self.setup(base_class, *_args)
					base_class.include InstanceMethods
					base_class.extend  ClassMethods
				end
			end

			Lennarb::Plugin.register(:test_plugin, TestPlugin)

      class UsersController < Lennarb::Application::Base
        plugin :test_plugin

        before do |req, res|
          req['x-users-controller-before-hook'] = 'Users Controller Before Hook'
        end

        after do |req, res|
          req['x-users-controller-after-hook'] = 'Users Controller After Hook'
        end

        get '/users/test' do |_req, res|
          res.status = 200
          res.html('Users Controller Response')
        end

        get '/users/plugin' do |_req, res|
          res.status = 200
          res.html(test_plugin_method)
        end
      end

      class PostsController < Lennarb::Application::Base
        get '/posts/test' do |_req, res|
          res.status = 200
          res.html('Posts Controller Response')
        end
      end

			class MyApp < Lennarb::Application::Base
        mount UsersController
        mount PostsController

				plugin :test_plugin

				test_plugin_class_method

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

				post '/json' do |req, res|
					begin
						res.status = 201
						JSON.parse(req.body)
						res.json(req.body)
					rescue JSON::ParserError
						res.status = 500
						result = { error: 'Invalid JSON body' }.to_json
						res.json(result)
					end
				end

				get '/plugin' do |_req, res|
					res.status = 200
					res.html(test_plugin_method)
				end
			end

			def app = MyApp.run!

      def test_users_controller
        get '/users/test'

        assert_predicate last_response, :ok?
        assert_equal 'Users Controller Response', last_response.body
      end
      
			def test_posts_controller
				get '/posts/test'

				assert_predicate last_response, :ok?
        assert_equal 'Posts Controller Response', last_response.body
      end

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

			def test_post_with_valid_json_body
        json_body = '{"key":"value"}'
				headers = { 'CONTENT_TYPE' => 'application/json' }

				post '/json', json_body, headers

				assert_equal 201, last_response.status
				body = JSON.parse(last_response.body)
				assert_equal({ "key" => "value" }, body)
			end

			def test_post_with_invalid_json_body
				json_body = '{"key":"value'

				headers = { 'CONTENT_TYPE' => 'application/json' }

				post '/json', json_body, headers

				assert_equal 500, last_response.status
				assert_equal({ "error" => "Invalid JSON body" }, JSON.parse(last_response.body))
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

			def test_mount_hooks_must_be_executed
				get '/users/test'

				assert_equal 'Before Hook', last_request.env['x-before-hook']
				assert_equal 'After Hook', last_request.env['x-after-hook']
				assert_equal 'Users Controller Before Hook', last_request.env['x-users-controller-before-hook']
				assert_equal 'Users Controller After Hook', last_request.env['x-users-controller-after-hook']
			end

			def test_mount_routes_with_plugins_must_be_executed
				get '/users/plugin'

				assert_predicate last_response, :ok?
				assert_equal 'Plugin Method Executed', last_response.body
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

				assert_includes MyApp._middlewares, [Lennarb::Application::TestBase::MockedMiddleware, [], nil]
			end
		end
	end
end
