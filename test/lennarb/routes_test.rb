require "test_helper"

class RoutesTest < Minitest::Test
  def setup
    @routes = Lennarb::Routes.new
  end

  test "initializes with an empty route store" do
    assert_instance_of Lennarb::RouteNode, @routes.instance_variable_get(:@store)
    assert_equal false, @routes.frozen?
  end

  test "defines root route" do
    @routes.root do |req, res|
      "root"
    end

    route = @routes.match_route([], :GET)

    assert_pattern do
      route => [Proc, Hash]
    end
  end

  test "defines GET route" do
    @routes.get "/foo" do |req, res|
      "foo"
    end

    block, _ = @routes.match_route(["foo"], :GET)

    refute_nil(block)
  end

  test "defines POST route" do
    @routes.post "/foo" do |req, res|
      "foo"
    end

    block, _ = @routes.match_route(["foo"], :POST)

    refute_nil(block)
  end

  test "defines PATCH route" do
    @routes.patch "/foo/:id" do |req, res|
      "foo"
    end

    block, _ = @routes.match_route(["foo", "123"], :PATCH)

    refute_nil(block)
  end

  test "defines PUT route" do
    @routes.put "/foo/:id" do |req, res|
      "foo"
    end

    block, _ = @routes.match_route(["foo", "123"], :PUT)

    refute_nil(block)
  end

  test "defines DELETE route" do
    @routes.delete "/foo/:id" do |req, res|
      "foo"
    end

    block, _ = @routes.match_route(["foo", "123"], :DELETE)

    refute_nil(block)
  end

  test "defines OPTIONS route" do
    @routes.options "/foo/:id" do |req, res|
      "foo"
    end

    block, _ = @routes.match_route(["foo", "123"], :OPTIONS)

    refute_nil(block)
  end

  test "defines HEAD route" do
    @routes.head "/foo/:id" do |req, res|
      "foo"
    end

    block, _ = @routes.match_route(["foo", "123"], :HEAD)

    refute_nil(block)
  end

  test "sets route segment constraint" do
    @routes.get "/foo/:id" do |req, res|
      "foo #{id}"
    end

    route = @routes.match_route(["foo", "123"], :GET)

    refute_nil(route)
    assert_pattern do
      route => [Proc, { id: "123" }]
    end
  end

  test "freezes routes" do
    @routes.get "/foo" do |req, res|
      "foo"
    end

    @routes.freeze

    assert @routes.frozen?

    assert_raises(RuntimeError) do
      @routes.get "/bar" do |req, res|
        "bar"
      end
    end
  end

  test "matches nested routes" do
    @routes.get "/users/:user_id/posts/:post_id" do |req, res|
      "user post"
    end

    block, params = @routes.match_route(["users", "42", "posts", "123"], :GET)

    refute_nil(block)
    assert_equal "42", params[:user_id]
    assert_equal "123", params[:post_id]
  end

  test "prioritizes static routes over dynamic routes" do
    @routes.get "/users/profile" do |req, res|
      "static profile"
    end

    @routes.get "/users/:id" do |req, res|
      "dynamic user"
    end

    block1, _ = @routes.match_route(["users", "profile"], :GET)
    block2, params = @routes.match_route(["users", "42"], :GET)

    refute_nil(block1)
    refute_nil(block2)
    assert_equal "42", params[:id]
  end
end
