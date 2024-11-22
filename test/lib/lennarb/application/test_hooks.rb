# frozen_string_literal: true

require 'test_helper'

class Lennarb
  module Application
    class HooksTest < Minitest::Test
      include Rack::Test::Methods

      class AdminController < Lennarb
        plugin :hooks

        before ['/', '/:id'] do |_req, res|
          @admin_authenticated = true
          res['x-admin-authenticated'] = 'x-admin-authenticated'
        end

        after '/:id' do |_req, res|
          res.write(' - Processed')
        end

        get '/' do |_req, res|
          res.status = 200
          res.text("Admin Dashboard#{@admin_authenticated ? ' (Authenticated)' : ''}")
        end

        get '/:id' do |req, res|
          res.status = 200
          res.text("Admin User #{req.params[:id]}#{@admin_authenticated ? ' (Authenticated)' : ''}")
        end
      end

      class MainApp < Lennarb
        plugin :mount
        plugin :hooks

        before '*' do |_req, _res|
          @global_executed = true
        end

        after '*' do |_req, res|
          res.write(' - Done')
          res['x-global-executed'] = 'x-global-executed'
        end

        mount AdminController, at: '/admin'

        get '/' do |_req, res|
          res.status = 200
          res.text("Home#{@global_executed ? ' (Global)' : ''}")
        end
      end

      def app
        @app ||= MainApp.freeze!
      end

      def test_global_hooks
        get '/'

        assert_equal 200, last_response.status
        assert_equal 'Home (Global) - Done', last_response.body
        assert_equal 'x-global-executed', last_response.headers['x-global-executed']
      end

      def test_admin_dashboard_with_hooks
        get '/admin'

        assert_equal 200, last_response.status
        assert_equal 'Admin Dashboard (Authenticated) - Done', last_response.body
        assert_equal 'x-admin-authenticated', last_response.headers['x-admin-authenticated']
      end

      def test_admin_user_with_hooks
        get '/admin/123'

        assert_equal 200, last_response.status
        assert_equal 'Admin User 123 (Authenticated) - Processed - Done', last_response.body
        assert_equal 'x-admin-authenticated', last_response.headers['x-admin-authenticated']
      end
    end
  end
end
