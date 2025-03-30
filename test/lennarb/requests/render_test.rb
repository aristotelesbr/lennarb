require "test_helper"

class RenderTest < Minitest::Test
  include Rack::Test::Methods

  def app = SampleApp

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
    SampleApp.routes.get "/error" do |_, _|
      raise Lennarb::Error
    end

    get "/error"

    assert_equal 500, last_response.status
    assert_equal "Internal Server Error (Lennarb::Error)", last_response.body
  end

  test "different HTTP methods for same path" do
    app.routes.post "/api" do |req, res|
      res.json({action: "create"})
    end

    app.routes.get "/api" do |req, res|
      res.json({action: "index"})
    end

    get "/api"
    assert_equal 200, last_response.status
    assert_equal "{\"action\":\"index\"}", last_response.body

    post "/api"
    assert_equal 200, last_response.status
    assert_equal "{\"action\":\"create\"}", last_response.body
  end

  test "route with parameters" do
    app.routes.get "/users/:id" do |req, res|
      res.json({id: req.params[:id]})
    end

    get "/users/42"

    assert_equal 200, last_response.status
    assert_equal "{\"id\":\"42\"}", last_response.body
  end
end
