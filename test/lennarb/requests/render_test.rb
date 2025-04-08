require "test_helper"

class RenderTest < Minitest::Test
  include Rack::Test::Methods

  def app
    SampleApp
  end

  test "GET root path" do
    get "/"

    assert_equal 200, last_response.status
    assert_equal "Root path", last_response.body
    assert_equal "text/html", last_response.headers["content-type"]
  end

  test "GET /hello" do
    get "/hello"

    assert_equal 200, last_response.status
    assert_equal "{\"message\":\"Hello World\"}", last_response.body
    assert_equal "application/json", last_response.headers["content-type"]
  end

  test "GET /nonexistent" do
    get "/nonexistent"

    assert_equal 404, last_response.status
    assert_equal "Not Found", last_response.body
  end

  test "POST /hello" do
    post "/hello"

    assert_equal 404, last_response.status
  end

  test "GET /error" do
    get "/error"

    assert_equal 500, last_response.status
    assert_match(/Lennarb::Error/, last_response.body)
  end

  test "different HTTP methods for same path" do
    get "/api"
    assert_equal 200, last_response.status
    assert_equal "{\"action\":\"index\"}", last_response.body

    post "/api"
    assert_equal 200, last_response.status
    assert_equal "{\"action\":\"create\"}", last_response.body
  end

  test "route with parameters" do
    get "/users/42"

    assert_equal 200, last_response.status
    assert_equal "{\"id\":\"42\"}", last_response.body
  end
end
