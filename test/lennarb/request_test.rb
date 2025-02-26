require "test_helper"

module Lennarb
  class TestRequest < Minitest::Test
    test "initialize" do
      request = Lennarb::Request.new({})

      assert_instance_of(Lennarb::Request, request)
    end

    test "params" do
      request = Lennarb::Request.new({"QUERY_STRING" => "foo=bar"})

      assert_equal({foo: "bar"}, request.params)
    end

    test "query params" do
      request = Lennarb::Request.new({"QUERY_STRING" => "foo=bar"})

      assert_equal({foo: "bar"}, request.query_params)
    end

    test "query params with empty query string" do
      request = Lennarb::Request.new({})

      assert_empty(request.query_params)
    end

    test "content type" do
      request = Lennarb::Request.new({"HTTP_CONTENT_TYPE" => "application/json"})

      assert_equal("application/json", request.content_type)
    end

    test "content length" do
      request = Lennarb::Request.new({"HTTP_CONTENT_LENGTH" => "42"})

      assert_equal("42", request.content_length)
    end

    test "body" do
      request = Lennarb::Request.new({"rack.input" => StringIO.new("foo")})

      assert_equal("foo", request.body)
    end

    test "path" do
      request = Lennarb::Request.new({"PATH_INFO" => "/foo"})

      assert_equal("/foo", request.path)
    end

    test "xhr?" do
      request = Lennarb::Request.new({"HTTP_X_REQUESTED_WITH" => "XMLHttpRequest"})

      assert(request.xhr?)
    end

    test "json?" do
      request = Lennarb::Request.new({"HTTP_CONTENT_TYPE" => "application/json"})

      assert(request.json?)
    end

    test "json body" do
      request = Lennarb::Request.new({"HTTP_CONTENT_TYPE" => "application/json", "rack.input" => StringIO.new('{"foo":"bar"}')})

      assert_equal({foo: "bar"}, request.json_body)
    end

    test "json body with invalid JSON" do
      request = Lennarb::Request.new({"HTTP_CONTENT_TYPE" => "application/json", "rack.input" => StringIO.new('{"foo":"bar"')})

      assert_nil(request.json_body)
    end
  end
end
