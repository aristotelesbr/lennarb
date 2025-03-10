require "test_helper"

class RotesTest < Minitest::Test
  test "defines root route" do
    routes = Lennarb::Routes.new do
      root do |req, res|
      end
    end

    route = routes.match_route([], :GET)

    assert_pattern do
      route => [Proc, Hash]
    end
  end

  test "defines GET route" do
    routes = Lennarb::Routes.new do
      get "/foo" do |req, res|
      end
    end

    block, _ = routes.match_route(["foo"], :GET)

    refute_nil(block)
  end

  test "defines POST route" do
    routes = Lennarb::Routes.new do
      post "/foo" do |req, res|
      end
    end

    block, _ = routes.match_route(["foo"], :POST)

    refute_nil(block)
  end

  test "defines PATCH route" do
    routes = Lennarb::Routes.new do
      patch "/foo/:id" do |req, res|
      end
    end

    block, _ = routes.match_route(["foo", "123"], :PATCH)

    refute_nil(block)
  end

  test "defines PUT route" do
    routes = Lennarb::Routes.new do
      put "/foo/:id" do |req, res|
      end
    end

    block, _ = routes.match_route(["foo", "123"], :PUT)

    refute_nil(block)
  end

  test "defines DELETE route" do
    routes = Lennarb::Routes.new do
      delete "/foo/:id" do |req, res|
      end
    end

    block, _ = routes.match_route(["foo", "123"], :DELETE)

    refute_nil(block)
  end

  test "defines OPTIONS route" do
    routes = Lennarb::Routes.new do
      options "/foo/:id" do |req, res|
      end
    end

    block, _ = routes.match_route(["foo", "123"], :OPTIONS)

    refute_nil(block)
  end

  test "defines HEAD route" do
    routes = Lennarb::Routes.new do
      head "/foo/:id" do |req, res|
      end
    end

    block, _ = routes.match_route(["foo", "123"], :HEAD)

    refute_nil(block)
  end

  test "sets route segment constraint" do
    routes = Lennarb::Routes.new do
      get "/foo/:id" do |req, res|
      end
    end

    route = routes.match_route(["foo", "123"], :GET)

    refute_nil(route)
    assert_pattern do
      route => [Proc, { id: "123" }]
    end
  end

  test "add root route" do
    route = Lennarb::Routes.new do
      root do |req, res|
      end
    end

    block, _ = route.match_route([], :GET)

    refute_nil(block)
  end
end
