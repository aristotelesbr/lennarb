# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

require 'test_helper'

class Lennarb
	class RouteNodeTest < Minitest::Test
		def setup
			@route_node = Lennarb::RouteNode.new

			@route_node.add_route(['posts'], 'GET', proc { 'List of posts' })
			@route_node.add_route(['posts', ':id'], 'GET', proc { |id| "Post #{id}" })
		end

		def test_add_route
			assert @route_node.static_children.key?('posts')
			dynamic_node = @route_node.static_children['posts'].dynamic_children.find { |node| node.param_key == :id }

			refute_nil dynamic_node
		end

		def test_match_valid_route
			block, params = @route_node.match_route(['posts'], 'GET')

			assert_equal 'List of posts', block.call
			assert_empty params
		end

		def test_match_route_with_parameters
			block, params = @route_node.match_route(%w[posts 123], 'GET')

			assert_equal 'Post 123', block.call(params[:id])
			assert_equal({ id: '123' }, params)
		end

		def test_match_invalid_route
			block, params = @route_node.match_route(['unknown'], 'GET')

			assert_nil block
			assert_nil params
		end
	end
end
