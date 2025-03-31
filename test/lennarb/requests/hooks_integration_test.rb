require "test_helper"

class HooksIntegrationTest < Minitest::Test
  include Rack::Test::Methods

  class TestApp < Lennarb::App
    before do |req, res|
      req["hook_executed"] = "yes"
      if req.path == "/admin"
        res["X-Admin-Access"] = "granted"
      end
    end

    after do |req, res|
      res["X-Hook-Executed"] = "yes"
    end

    get "/" do |req, res|
      res.text("Root with hook: #{req["hook_executed"]}")
    end

    get "/admin" do |req, res|
      res.text("Admin with hook: #{req["hook_executed"]}")
    end
  end

  def app
    @app ||= TestApp.new.tap(&:initialize!)
  end

  test "executes before hook" do
    get "/"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Root with hook: yes"
  end

  test "executes after hook on root" do
    get "/"

    assert_equal 200, last_response.status
    assert_equal "yes", last_response.headers["X-Hook-Executed"]
  end

  test "executes after hook on admin" do
    get "/admin"

    assert_equal 200, last_response.status
    assert_equal "yes", last_response.headers["X-Hook-Executed"]
  end

  test "before hook modifies admin response" do
    get "/admin"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Admin with hook: yes"
    assert_equal "granted", last_response.headers["X-Admin-Access"]
  end

  test "hooks don't affect 404 responses" do
    get "/nonexistent"

    refute last_response.headers["X-Hook-Executed"]
    refute last_response.headers["hook_executed"]
    assert_equal 404, last_response.status
  end
end
