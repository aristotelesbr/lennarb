# frozen_string_literal: true

require 'test_helper'

class Lennarb
  module Application
    class TestPlugin < Minitest::Test
      include Rack::Test::Methods

      module TextHelpers
        module InstanceMethods
          def trim_text(text)
            text.strip
          end
        end

        def self.configure(app, *)
          app.include(InstanceMethods)
        end
      end

      Lennarb::Plugin.register(:text_helpers, TextHelpers)

      class TestApp < Lennarb
        plugin :text_helpers

        get '/api/users' do |_req, res|
          result_from_other_service = '  some text with spaces  '

          result = trim_text(result_from_other_service)
          res.status = 200
          res.text(result)
        end
      end

      def app = TestApp.freeze!

      def test_plugin_extended_route
        get '/api/users'

        assert_equal 200, last_response.status
        assert_equal 'some text with spaces', last_response.body
      end
    end
  end
end
