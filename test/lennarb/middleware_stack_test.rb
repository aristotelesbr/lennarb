require "test_helper"

class MiddlewareStackTest < Minitest::Test
  test "middleware stack" do
    stack = Lennarb::MiddlewareStack.new
    stack.use Rack::ShowExceptions
    stack.use Rack::CommonLogger

    list = stack.to_a

    assert_equal 2, list.size
    assert_equal [Rack::ShowExceptions, [], nil], list[0]
    assert_equal [Rack::CommonLogger, [], nil], list[1]
  end

  test "prepends middleware" do
    stack = Lennarb::MiddlewareStack.new
    stack.use Rack::ShowExceptions
    stack.unshift Rack::Runtime

    list = stack.to_a

    assert_equal 2, list.size
    assert_equal [Rack::Runtime, [], nil], list[0]
    assert_equal [Rack::ShowExceptions, [], nil], list[1]
  end

  test "clear middleware" do
    stack = Lennarb::MiddlewareStack.new
    stack.use Rack::CommonLogger
    stack.use Rack::Runtime

    stack.clear

    assert_empty stack.to_a
  end
end
