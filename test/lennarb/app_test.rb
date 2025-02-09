require "test_helper"

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app = SampleApp.initializer!

  def test_root_path
    get "/"

    assert_equal 200, last_response.status
    assert_equal "Root path", last_response.body
    assert_equal "text/html", last_response.headers["content-type"]
  end

  def test_get_request
    get "/hello"

    assert_equal 200, last_response.status
    assert_equal "{\"message\":\"Hello World\"}", last_response.body
    assert_equal "application/json", last_response.headers["content-type"]
  end

  def test_not_found
    get "/nonexistent"

    assert_equal 404, last_response.status
    assert_equal "Not Found", last_response.body
  end

  def test_method_not_allowed
    post "/hello"

    assert_equal 404, last_response.status
  end

  def test_internal_server_error
    SampleApp.get "/error" do
      raise StandardError
    end

    get "/error"

    assert_equal 500, last_response.status
    assert_equal "Internal Server Error - StandardError", last_response.body
  end
end
