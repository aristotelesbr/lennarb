require "test_helper"

module Lennarb
  class RequestTest < Minitest::Test
    test "initialize with route params" do
      request = Lennarb::Request.new({"QUERY_STRING" => "foo=bar"}, {id: "123"})

      assert_equal({foo: "bar", id: "123"}, request.params)
    end

    test "initialize without route params" do
      request = Lennarb::Request.new({"QUERY_STRING" => "foo=bar"})

      assert_equal({foo: "bar"}, request.params)
    end

    test "path extraction" do
      request = Lennarb::Request.new({"PATH_INFO" => "/users/123?query=test"})

      assert_equal "/users/123", request.path
    end

    test "body reading" do
      input = StringIO.new('{"name":"test"}')
      request = Lennarb::Request.new({"rack.input" => input})

      assert_equal '{"name":"test"}', request.body
    end

    test "query params parsing" do
      request = Lennarb::Request.new({"QUERY_STRING" => "name=john&age=30"})

      assert_equal({name: "john", age: "30"}, request.query_params)
    end

    test "env access" do
      request = Lennarb::Request.new({"HTTP_USER_AGENT" => "test-agent"})

      assert_equal "test-agent", request["HTTP_USER_AGENT"]

      request["HTTP_USER_AGENT"] = "new-agent"
      assert_equal "new-agent", request["HTTP_USER_AGENT"]
    end

    test "headers access" do
      request = Lennarb::Request.new({
        "HTTP_USER_AGENT" => "test-agent",
        "HTTP_ACCEPT" => "application/json",
        "PATH_INFO" => "/test"
      })

      headers = request.headers
      assert_equal "test-agent", headers["HTTP_USER_AGENT"]
      assert_equal "application/json", headers["HTTP_ACCEPT"]
      refute headers.key?("PATH_INFO")
    end

    test "ip address" do
      request = Lennarb::Request.new({"REMOTE_ADDR" => "127.0.0.1"})

      assert_equal "127.0.0.1", request.ip
    end

    test "ip address with forwarded" do
      request = Lennarb::Request.new({
        "HTTP_X_FORWARDED_FOR" => "10.0.0.1, 10.0.0.2",
        "REMOTE_ADDR" => "127.0.0.1"
      })

      assert_equal "10.0.0.1", request.ip
    end

    test "secure request detection" do
      request = Lennarb::Request.new({"rack.url_scheme" => "https"})

      assert request.secure?

      request = Lennarb::Request.new({"rack.url_scheme" => "http"})

      refute request.secure?
    end

    test "common headers accessors" do
      request = Lennarb::Request.new({
        "HTTP_USER_AGENT" => "test-agent",
        "HTTP_ACCEPT" => "text/html",
        "HTTP_REFERER" => "http://example.com",
        "HTTP_HOST" => "test.com",
        "HTTP_CONTENT_LENGTH" => "100",
        "HTTP_CONTENT_TYPE" => "application/json"
      })

      assert_equal "test-agent", request.user_agent
      assert_equal "text/html", request.accept
      assert_equal "http://example.com", request.referer
      assert_equal "test.com", request.host
      assert_equal "100", request.content_length
      assert_equal "application/json", request.content_type
    end

    test "xhr detection" do
      request = Lennarb::Request.new({"HTTP_X_REQUESTED_WITH" => "XMLHttpRequest"})

      assert request.xhr?
      assert request.ajax?

      request = Lennarb::Request.new({})

      refute request.xhr?
      refute request.ajax?
    end

    test "json request detection" do
      request = Lennarb::Request.new({"HTTP_CONTENT_TYPE" => "application/json"})

      assert request.json?

      request = Lennarb::Request.new({"HTTP_CONTENT_TYPE" => "text/html"})

      refute request.json?
    end

    test "json body parsing" do
      input = StringIO.new('{"name":"test","age":30}')
      request = Lennarb::Request.new({
        "HTTP_CONTENT_TYPE" => "application/json",
        "rack.input" => input
      })

      assert_equal({name: "test", age: 30}, request.json_body)
    end

    test "json body parsing with invalid JSON" do
      input = StringIO.new('{"name":test"}')
      request = Lennarb::Request.new({
        "HTTP_CONTENT_TYPE" => "application/json",
        "rack.input" => input
      })

      assert_nil request.json_body
    end

    test "format detection" do
      request = Lennarb::Request.new({"PATH_INFO" => "/users.json"})

      assert_equal :json, request.format

      request = Lennarb::Request.new({"PATH_INFO" => "/users"})

      assert_nil request.format

      request = Lennarb::Request.new({"PATH_INFO" => "/users."})

      assert_nil request.format
    end

    test "request method checks" do
      methods = {
        "GET" => :get?,
        "POST" => :post?,
        "PUT" => :put?,
        "DELETE" => :delete?,
        "HEAD" => :head?,
        "PATCH" => :patch?
      }

      methods.each do |method, check|
        request = Lennarb::Request.new({"REQUEST_METHOD" => method})

        assert request.send(check), "Expected #{check} to be true for #{method}"

        other_methods = methods.keys - [method]
        other_checks = methods.values - [check]

        other_methods.zip(other_checks).each do |other_method, other_check|
          request = Lennarb::Request.new({"REQUEST_METHOD" => other_method})

          refute request.send(check), "Expected #{check} to be false for #{other_method}"
        end
      end
    end
  end
end
