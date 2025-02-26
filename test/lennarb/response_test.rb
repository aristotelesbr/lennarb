require "test_helper"

module Lennarb
  class TestResponse < Minitest::Test
    test "default instance variables" do
      response = Lennarb::Response.new

      assert_equal 200, response.status
      assert_empty(response.headers)
      assert_empty response.body
      assert_equal 0, response.length
    end

    test "set and get response header" do
      response = Lennarb::Response.new

      response["location"] = "/"

      assert_equal "/", response["location"]
    end

    test "write to response body" do
      response = Lennarb::Response.new

      response.write("Hello World!")

      assert_equal "Hello World!", response.body.first
    end

    test "set response status" do
      response = Lennarb::Response.new

      response.status = 200

      assert_equal 200, response.status
    end

    test "set response content type" do
      response = Lennarb::Response.new

      response["content-type"] = "text/html"

      assert_equal "text/html", response["content-type"]
    end

    test "set response content length" do
      response = Lennarb::Response.new

      response["content-length"] = 12

      assert_equal 12, response["content-length"]
    end

    test "finish response" do
      response = Lennarb::Response.new
      response["content-type"] = "text/plain"

      response.finish

      assert_equal 0, response.length
      assert_equal "text/plain", response["content-type"]
    end
  end
end
