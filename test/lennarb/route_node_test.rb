require "test_helper"

module Lennarb
  class RouteNodeTest < Minitest::Test
    test "add route" do
      router = Lennarb::RouteNode.new
      router.add_route(["posts"], "GET", proc { "List of posts" })
      router.add_route(["posts", ":id"], "GET", proc { |id| "Post #{id}" })

      dynamic_node = router.static_children["posts"].dynamic_children[:id]

      assert router.static_children.key?("posts")
      refute_nil dynamic_node
    end

    test "match valid route" do
      router = Lennarb::RouteNode.new
      router.add_route(["posts"], "GET", proc { "List of posts" })
      router.add_route(["posts", ":id"], "GET", proc { |id| "Post #{id}" })

      block, params = router.match_route(["posts"], "GET")

      assert_equal "List of posts", block.call
      assert_empty params
    end

    test "match route with parameters" do
      router = Lennarb::RouteNode.new
      router.add_route(["posts"], "GET", proc { "List of posts" })
      router.add_route(["posts", ":id"], "GET", proc { |id| "Post #{id}" })

      block, params = router.match_route(%w[posts 123], "GET")

      assert_equal "Post 123", block.call(params[:id])
      assert_equal({id: "123"}, params)
    end

    test "match invalid route" do
      router = Lennarb::RouteNode.new
      router.add_route(["posts"], "GET", proc { "List of posts" })
      router.add_route(["posts", ":id"], "GET", proc { |id| "Post #{id}" })

      block, params = router.match_route(["unknown"], "GET")

      assert_nil block
      assert_nil params
    end

    test "handles different variable names in nested routes with common prefixes" do
      router = Lennarb::RouteNode.new
      router.add_route(["foo", ":foo"], "GET", proc { "foo" })
      router.add_route(%w[foo special], "GET", proc { "special" })
      router.add_route(["foo", ":id", "bar"], "GET", proc { "bar" })

      _, params = router.match_route(%w[foo 23], "GET")

      assert_equal({foo: "23"}, params)
      _, params = router.match_route(%w[foo special], "GET")

      assert_empty(params)
      _, params = router.match_route(%w[foo 24 bar], "GET")

      assert_equal({id: "24"}, params)
    end

    test "allows merging different HTTP methods on same path" do
      router_one = Lennarb::RouteNode.new
      router_two = Lennarb::RouteNode.new
      router_one.add_route(["posts"], "GET", proc { "List posts" })
      router_two.add_route(["posts"], "POST", proc { "Create post" })

      router_one.merge!(router_two)

      assert router_one.static_children["posts"].blocks.key?("GET")
      assert router_one.static_children["posts"].blocks.key?("POST")
    end

    test "merges nested routes correctly" do
      router_one = Lennarb::RouteNode.new
      router_two = Lennarb::RouteNode.new
      router_one.add_route(["posts", "draft"], "GET", proc { "Draft posts" })
      router_two.add_route(["posts", "published"], "GET", proc { "Published posts" })

      router_one.merge!(router_two)

      assert router_one.static_children["posts"].static_children.key?("draft")
      assert router_one.static_children["posts"].static_children.key?("published")
    end

    test "raises error when merging duplicate HTTP methods" do
      router_one = Lennarb::RouteNode.new
      router_two = Lennarb::RouteNode.new
      router_one.add_route(["posts"], "GET", proc { "List posts" })
      router_two.add_route(["posts"], "GET", proc { "List posts" })

      assert_raises(Lennarb::RouteNode::DuplicateRouteError) do
        router_one.merge!(router_two)
      end
    end

    test "raises error when merging duplicate HTTP methods in nested routes" do
      router_one = Lennarb::RouteNode.new
      router_two = Lennarb::RouteNode.new
      router_one.add_route(["posts", ":id"], "GET", proc { "Show post" })
      router_two.add_route(["posts", ":id"], "GET", proc { "Show post" })

      assert_raises(Lennarb::RouteNode::DuplicateRouteError) do
        router_one.merge!(router_two)
      end
    end
  end
end
