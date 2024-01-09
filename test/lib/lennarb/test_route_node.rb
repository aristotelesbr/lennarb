# frozen_string_literal: true

require 'test_helper'

module Lennarb
  class RouteNodeTest < Minitest::Test
    def setup
      @route_node = Lennarb::RouteNode.new

      # Adicionando rotas de exemplo
      @route_node.add_route(['posts'], 'GET', proc { 'List of posts' })
      @route_node.add_route(['posts', ':id'], 'GET', proc { |id| "Post #{id}" })
    end

    def test_add_route
      # Verificar se as rotas foram adicionadas corretamente
      assert @route_node.children.key?('posts')
      assert @route_node.children['posts'].children.key?(:param)
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
