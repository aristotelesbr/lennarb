require "test_helper"
require "stringio"
require "rack/mock"

module Lennarb
  module Middleware
    class RequestLoggerTest < Minitest::Test
      class TestApp
        def call(env)
          [200, {"Content-Type" => "text/plain"}, ["OK"]]
        end
      end

      def setup
        @output = StringIO.new
        @std_logger = ::Logger.new(@output)
        @std_logger.formatter = proc { |_, _, _, msg| "#{msg}\n" }

        app = TestApp.new

        @middleware = RequestLogger.new(app)

        mock_logger = Lennarb::Logger.new(@std_logger, colorize: false)

        @middleware.define_singleton_method(:logger) { |_ = nil| mock_logger }
      end

      test "formats duration correctly" do
        assert_equal "500ms", @middleware.send(:format_duration, 0.5)
        assert_equal "1.50s", @middleware.send(:format_duration, 1.5)
        assert_equal "1m 30s", @middleware.send(:format_duration, 90)
      end

      test "logs request with correct format" do
        env = Rack::MockRequest.env_for("/test?foo=bar", method: "GET")

        mock_params = {"foo" => "bar"}
        mock_request = Object.new
        mock_request.define_singleton_method(:request_method) { "GET" }
        mock_request.define_singleton_method(:path) { "/test" }
        mock_request.define_singleton_method(:params) { mock_params }

        Lennarb::Request.stub :new, mock_request do
          status, _, body = @middleware.call(env)

          assert_equal 200, status
          assert_equal ["OK"], body

          log_output = @output.string
          assert_match(/GET \/test/, log_output)
          assert_match(/Status: 200 OK/, log_output)
          assert_match(/Params:/, log_output)
        end
      end

      test "logs redirects" do
        env = Rack::MockRequest.env_for("/test", method: "GET")

        redirect_app = proc { [302, {"location" => "/other"}, []] }
        middleware = RequestLogger.new(redirect_app)

        mock_logger = Lennarb::Logger.new(@std_logger, colorize: false)
        middleware.define_singleton_method(:logger) { |_ = nil| mock_logger }

        mock_request = Object.new
        mock_request.define_singleton_method(:request_method) { "GET" }
        mock_request.define_singleton_method(:path) { "/test" }
        mock_request.define_singleton_method(:params) { {} }

        Lennarb::Request.stub :new, mock_request do
          middleware.call(env)

          log_output = @output.string
          assert_match(/Redirect: \/other/, log_output)
        end
      end

      test "selects correct color based on status code" do
        assert_equal :green, @middleware.send(:status_to_color, 200)
        assert_equal :yellow, @middleware.send(:status_to_color, 302)
        assert_equal :magenta, @middleware.send(:status_to_color, 404)
        assert_equal :red, @middleware.send(:status_to_color, 500)
        assert_equal :white, @middleware.send(:status_to_color, 600)
      end

      test "filters parameters" do
        mock_filter = Minitest::Mock.new
        filtered_params = {"email" => "[FILTERED]", "name" => "John"}
        mock_filter.expect :filter, filtered_params, [Hash]

        ParameterFilter.stub :new, mock_filter do
          result = @middleware.send(:filter_params, {"email" => "test@example.com", "name" => "John"})
          assert_equal filtered_params, result
        end

        mock_filter.verify
      end

      test "calculates request duration" do
        env = Rack::MockRequest.env_for("/test", method: "GET")

        slow_app = proc do |e|
          sleep 0.01
          [200, {}, ["OK"]]
        end

        middleware = RequestLogger.new(slow_app)

        duration_captured = nil
        mock_logger = Object.new
        mock_logger.define_singleton_method(:info) do |&block|
          message = block.call
          duration_captured = message if message.include?("(") && message.include?(")") && message.include?("GET")
        end
        middleware.define_singleton_method(:logger) { |_ = nil| mock_logger }

        mock_request = Object.new
        mock_request.define_singleton_method(:request_method) { "GET" }
        mock_request.define_singleton_method(:path) { "/test" }
        mock_request.define_singleton_method(:params) { {} }

        Lennarb::Request.stub :new, mock_request do
          middleware.call(env)

          assert_match(/\(\d+ms\)/, duration_captured)
        end
      end

      test "uses the logger configured on the app handling the request" do
        app_log = StringIO.new
        app_class = Class.new(Lennarb::App) do
          get("/") { |req, res| res.text("ok") }
        end
        app_class.config.set :logger, Lennarb::Logger.new(::Logger.new(app_log), colorize: false)
        app = app_class.new
        app.initialize!

        app.call({
          "REQUEST_METHOD" => "GET", "PATH_INFO" => "/", "QUERY_STRING" => "",
          "SERVER_NAME" => "x", "SERVER_PORT" => "80", "rack.url_scheme" => "http",
          "rack.input" => StringIO.new
        })

        assert_includes app_log.string, "GET /"
      end

      test "escapes control characters in the logged path" do
        middleware = Lennarb::Middleware::RequestLogger.new(->(_) { [200, {}, ["ok"]] })

        line = middleware.send(:filter_path, "/a/\e[1mPWNED\nStatus: 200 OK")

        refute_includes line, "\e"
        refute_includes line, "\n"
      end
    end
  end
end
