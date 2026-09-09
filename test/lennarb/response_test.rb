require "test_helper"

module Lennarb
  class ResponseTest < Minitest::Test
    test "default initialization" do
      response = Lennarb::Response.new

      assert_equal 200, response.status
      assert_equal({}, response.headers)
      assert_equal [], response.body
      assert_equal 0, response.length
    end

    test "setting and getting headers" do
      response = Lennarb::Response.new

      response["Content-Type"] = "text/plain"

      assert_equal "text/plain", response["Content-Type"]
    end

    test "writing to response" do
      response = Lennarb::Response.new

      response.write("Hello")
      response.write(" World")

      assert_equal ["Hello", " World"], response.body
      assert_equal 11, response.length
      assert_equal "11", response.headers["content-length"]
    end

    test "writing non-string to response" do
      response = Lennarb::Response.new

      response.write(123)

      assert_equal ["123"], response.body
      assert_equal 3, response.length
    end

    test "setting text content" do
      response = Lennarb::Response.new

      response.text("Hello World")

      assert_equal ["Hello World"], response.body
      assert_equal "text/plain", response.headers["content-type"]
    end

    test "setting html content" do
      response = Lennarb::Response.new

      response.html("<h1>Hello</h1>")

      assert_equal ["<h1>Hello</h1>"], response.body
      assert_equal "text/html", response.headers["content-type"]
    end

    test "setting json content" do
      response = Lennarb::Response.new

      response.json({message: "Hello", count: 42})

      assert_equal 1, response.body.size
      assert_includes response.body.first, '"message":"Hello"'
      assert_includes response.body.first, '"count":42'
      assert_equal "application/json", response.headers["content-type"]
    end

    test "handling json generation error" do
      response = Lennarb::Response.new

      JSON.stub :generate, ->(_) { raise JSON::GeneratorError, "Mock generator error" } do
        response.json({test: "data"})

        assert_equal 500, response.status
        assert_equal "text/plain", response.headers["content-type"]
        assert_includes response.body.first, "JSON generation error"
        # The exception message can carry inspect output of the object being
        # serialized, so it must not reach the client.
        refute_includes response.body.first, "Mock generator error"
      end
    end

    test "redirect response" do
      response = Lennarb::Response.new

      caught = catch(:halt) do
        response.redirect("/login")
      end

      status, headers, _body = caught

      assert_equal 302, status
      assert_equal "/login", headers["location"]
    end

    test "redirect with custom status" do
      response = Lennarb::Response.new

      caught = catch(:halt) do
        response.redirect("/permanent", 301)
      end

      status, headers, _body = caught

      assert_equal 301, status
      assert_equal "/permanent", headers["location"]
    end

    test "finish response" do
      response = Lennarb::Response.new
      response.status = 201
      response.headers["Content-Type"] = "text/plain"
      response.write("Created")

      result = response.finish

      assert_equal 201, result[0]
      assert_equal "text/plain", result[1]["Content-Type"]
      assert_equal ["Created"], result[2]
    end

    test "json rescues JSON::NestingError, which is not a GeneratorError" do
      response = Lennarb::Response.new
      deep = current = []
      200.times {
        nxt = []
        current << nxt
        current = nxt
      }

      response.json(deep)

      assert_equal 500, response.status
      assert_equal "text/plain", response.headers["content-type"]
    end

    test "json does not echo the exception message to the client" do
      response = Lennarb::Response.new
      leaky = Class.new do
        def initialize = @db_password = "s3cret"
        def to_json(*) = raise(JSON::GeneratorError, "cannot serialize #{inspect}")
      end.new

      response.json(leaky)

      assert_equal 500, response.status
      refute_includes response.body.join, "s3cret"
    end
  end
end
