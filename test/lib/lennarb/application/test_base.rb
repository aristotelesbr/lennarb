# frozen_string_literal: true

require 'json'
require 'test_helper'

class Lennarb
  module Application
    class TestSimplifiedBase < Minitest::Test
      include Rack::Test::Methods

      class TestApp < Lennarb
        get '/hello' do |_req, res|
          res.status = 200
          res.text('Hello World')
        end

        post '/users' do |_req, res|
          res.status = 201
          res.json({ status: 'created' }.to_json)
        end
      end

      def app = TestApp.freeze!

      def test_get_request
        get '/hello'

        assert_equal 200, last_response.status
        assert_equal 'Hello World', last_response.body
        assert_equal 'text/plain', last_response.headers['content-type']
      end

      def test_post_request
        post '/users'

        assert_equal 201, last_response.status
        assert_equal ({ 'status' => 'created' }), JSON.parse(last_response.body)
        assert_equal 'application/json', last_response.headers['content-type']
      end

      def test_not_found
        get '/nonexistent'

        assert_equal 404, last_response.status
        assert_equal 'Not Found', last_response.body
      end

      def test_method_not_allowed
        post '/hello'

        assert_equal 404, last_response.status
      end
    end
  end
end
