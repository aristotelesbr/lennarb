# frozen_string_literal: true

require 'test_helper'

class Lennarb
  module Application
    class MiddlewareTest < Minitest::Test
      include Rack::Test::Methods

      class TimingMiddleware
        def initialize(app)
          @app = app
        end

        def call(env)
          start_time = Time.now
          status, headers, body = @app.call(env)
          duration = Integer(((Time.now - start_time) * 1000), 10)

          headers = headers.dup # Garantimos que headers seja mutável
          headers['X-Response-Time'] = duration.to_s
          [status, headers, body]
        end
      end

      class AuthMiddleware
        def initialize(app, options = {})
          @app = app
          @protected_paths = options[:protected_paths] || []
        end

        def call(env)
          path = env[Rack::PATH_INFO]

          if protected_route?(path)
            authenticate_request(env)
          else
            @app.call(env)
          end
        end

        private

        def protected_route?(path)
          @protected_paths.any? { |protected_path| path.start_with?(protected_path) }
        end

        def authenticate_request(env)
          token = env['HTTP_AUTHORIZATION']

          if token == 'secret-token'
            status, headers, body = @app.call(env)
            headers = headers.dup # Garantimos que headers seja mutável
            headers['X-Auth-Valid'] = 'true'
            [status, headers, body]
          else
            [401, { 'Content-Type' => 'text/plain' }, ['Unauthorized']]
          end
        end
      end

      class TestApp < Lennarb
        use TimingMiddleware
        use AuthMiddleware, protected_paths: ['/protected']

        get '/protected' do |_req, res|
          res.status = 200
          res.text('Protected Resource')
        end

        get '/public' do |_req, res|
          res.status = 200
          res.text('Public Resource')
        end

        get '/error' do |_req, _res|
          raise StandardError, 'Something went wrong'
        end
      end

      def app
        @app ||= TestApp.freeze!
      end

      def test_public_route
        get '/public'

        assert_equal 200, last_response.status
        assert_equal 'Public Resource', last_response.body
        assert last_response.headers['X-Response-Time'], 'Should have timing header'
      end

      def test_protected_route_with_valid_token
        get '/protected', {}, { 'HTTP_AUTHORIZATION' => 'secret-token' }

        assert_equal 200, last_response.status
        assert_equal 'Protected Resource', last_response.body
        assert_equal 'true', last_response.headers['X-Auth-Valid']
        assert last_response.headers['X-Response-Time'], 'Should have timing header'
      end

      def test_protected_route_without_token
        get '/protected'

        assert_equal 401, last_response.status
        assert_equal 'Unauthorized', last_response.body
      end

      def test_error_handling
        get '/error'

        assert_equal 500, last_response.status
        assert_match(/Internal Server Error/, last_response.body)
        assert last_response.headers['X-Response-Time'], 'Should have timing header'
      end

      def test_middleware_chain_order
        get '/protected', {}, { 'HTTP_AUTHORIZATION' => 'secret-token' }

        assert_equal 200, last_response.status
        assert last_response.headers['X-Response-Time'], 'Timing middleware should be executed'
        assert_equal 'true', last_response.headers['X-Auth-Valid'], 'Auth middleware should be executed'
      end
    end
  end
end
