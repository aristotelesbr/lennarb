require "test_helper"

class Lennarb
  class RouteNodeTest < Minitest::Test
    def setup
      @route_node = Lennarb::RouteNode.new

      @route_node.add_route(["posts"], "GET", proc { "List of posts" })
      @route_node.add_route(["posts", ":id"], "GET", proc { |id| "Post #{id}" })
    end

    def test_add_route
      assert @route_node.static_children.key?("posts")
      dynamic_node = @route_node.static_children["posts"].dynamic_children[:id]

      refute_nil dynamic_node
    end

    def test_match_valid_route
      block, params = @route_node.match_route(["posts"], "GET")

      assert_equal "List of posts", block.call
      assert_empty params
    end

    def test_match_route_with_parameters
      block, params = @route_node.match_route(%w[posts 123], "GET")

      assert_equal "Post 123", block.call(params[:id])
      assert_equal({id: "123"}, params)
    end

    def test_match_invalid_route
      block, params = @route_node.match_route(["unknown"], "GET")

      assert_nil block
      assert_nil params
    end

    def test_different_variables_in_common_nested_routes
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

    def test_merge
      router = Lennarb::RouteNode.new
      router.add_route(["posts"], "GET", proc { "List of posts" })
      router.add_route(["posts", ":id"], "GET", proc { |id| "Post #{id}" })

      router.merge!(router)
    end

    def test_merge_variables_in_different_routes
      router = Lennarb::RouteNode.new
      router.add_route(["posts"], "GET", proc { "List of posts" })
      router.add_route(["posts", ":id"], "GET", proc { |id| "Post #{id}" })
      router.add_route(["posts", ":id", "comments"], "GET", proc { |id| "Comments of post #{id}" })

      router.merge!(router)
    end
  end
end
