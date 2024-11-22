# frozen_string_literal: true

require 'test_helper'

class Lennarb
  class MountTest < Minitest::Test
    include Rack::Test::Methods

    class AdminController < Lennarb
      get '/' do |_req, res|
        res.status = 200
        res.text('Admin Dashboard')
      end

      get '/users' do |_req, res|
        res.status = 200
        res.text('Admin Users')
      end

      get '/users/:id' do |req, res|
        res.status = 200
        res.text("User #{req.params[:id]}")
      end
    end

    class ApiController < Lennarb
      get '/status' do |_req, res|
        res.status = 200
        res.json({ status: 'ok' })
      end
    end

    class MainApp < Lennarb
      plugin :mount

      mount AdminController, at: '/admin'
      mount ApiController, at: '/api'

      get '/' do |_req, res|
        res.status = 200
        res.text('Home')
      end
    end

    def app = MainApp.freeze!

    def test_routes_with_prefix
      get '/'

      assert_equal 200, last_response.status
      assert_equal 'Home', last_response.body
    end

    def test_admin_dashboard
      get '/admin'

      assert_equal 200, last_response.status
      assert_equal 'Admin Dashboard', last_response.body
    end

    def test_admin_users
      get '/admin/users'

      assert_equal 200, last_response.status
      assert_equal 'Admin Users', last_response.body
    end
  end
end
