require "test_helper"

# Every example published in readme.md, README.pt-BR.md and
# guides/getting-started/readme.md must actually run. A documented example that
# raises is a defect, not documentation.
class ReadmeExamplesTest < Minitest::Test
  include Rack::Test::Methods

  class DocumentedApp < Lennarb::App
    get("/") { |req, res| res.html("<h1>Welcome to Lennarb!</h1>") }
    get("/hello/:name") { |req, res| res.html("Hello, #{req.params[:name]}!") }
    post("/users") { |req, res| res.json(id: 1, **req.json_body) }
  end

  def app
    @app ||= DocumentedApp.new.initialize!
  end

  test "the documented root route" do
    get "/"

    assert_equal 200, last_response.status
    assert_equal "<h1>Welcome to Lennarb!</h1>", last_response.body
    assert_equal "text/html", last_response.headers["content-type"]
  end

  test "the documented dynamic route" do
    get "/hello/aristoteles"

    assert_equal 200, last_response.status
    assert_equal "Hello, aristoteles!", last_response.body
  end

  test "the documented JSON route" do
    post "/users", '{"name":"lenna"}', {"CONTENT_TYPE" => "application/json"}

    assert_equal 200, last_response.status
    assert_equal({"id" => 1, "name" => "lenna"}, JSON.parse(last_response.body))
  end

  test "an undocumented path is a 404" do
    get "/nope"

    assert_equal 404, last_response.status
    assert_equal "Not Found", last_response.body
  end
end
