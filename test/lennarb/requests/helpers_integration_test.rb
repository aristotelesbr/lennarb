require "test_helper"

class HelpersIntegrationTest < Minitest::Test
  include Rack::Test::Methods

  setup do
    @app_class = Class.new(Lennarb::App) do
      helpers do
        def current_user
          "Ari"
        end

        def app_name
          "Test App"
        end

        def format_message(msg)
          "#{msg} from #{app_name}"
        end

        def param_value(key)
          req.params[key]
        end
      end

      get "/" do |req, res|
        res.text("Welcome #{current_user} to #{app_name}")
      end

      get "/eval" do |req, res|
        res.text("Welcome #{current_user} to #{app_name} (eval)")
      end

      get "/format/:message" do |req, res|
        res.text(format_message(req.params[:message]))
      end

      get "/param/:key" do |req, res|
        res.text("Value: #{param_value(:key)}")
      end

      # Nova rota para testar múltiplos helpers
      get "/welcome" do |req, res|
        res.text(format_message("Welcome #{current_user}"))
      end
    end

    @app = @app_class.new
    @app.initialize!
  end

  attr_reader :app

  test "helpers in regular routes" do
    get "/"
    assert_equal 200, last_response.status
    assert_equal "Welcome Ari to Test App", last_response.body
  end

  test "helpers in instance_eval routes" do
    get "/eval"
    assert_equal 200, last_response.status
    assert_equal "Welcome Ari to Test App (eval)", last_response.body
  end

  test "helpers with request parameters" do
    get "/format/Hello"
    assert_equal 200, last_response.status
    assert_equal "Hello from Test App", last_response.body
  end

  test "helpers can access request parameters" do
    get "/param/user"
    assert_equal 200, last_response.status
    assert_equal "Value: user", last_response.body
  end

  test "multiple helpers work together" do
    get "/welcome"
    assert_equal 200, last_response.status
    assert_equal "Welcome Ari from Test App", last_response.body
  end
end
