# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'test_helper'

module Lenna
	class Router
		class TestBuilder < Minitest::Test
			def test_build
				cache = Cache.new
				root_node = Node.new({}, nil)
				builder = Builder.new(root_node)

				builder.call('GET', '/foo', -> { 'foo' }, cache)

				assert_pattern do
					root_node.children['foo'].children => ::Hash
					root_node.children['foo'].endpoint['GET'] => ::Proc
				end
			end

			def test_build_with_placeholder_and_endpoint
				cache = Cache.new
				root_node = Node.new({}, nil)
				builder = Builder.new(root_node)

				builder.call('GET', '/foo/:id', -> { 'foo' }, cache)

				assert_pattern do
					root_node.children['foo'] => Lenna::Node
					root_node.children['foo'].children[:placeholder] => Lenna::Node
					root_node.children['foo'].children[:placeholder].endpoint['GET'] => ::Proc
				end
			end

			def test_build_with_placeholder_and_endpoint_and_namespace
				cache = Cache.new
				root_node = Node.new({}, nil)
				builder = Builder.new(root_node)

				builder.call('GET', 'api/v1/foo/:id', -> { 'foo' }, cache)

				assert_pattern do
					root_node.children['api'] => Lenna::Node
					root_node.children['api'].children['v1'] => Lenna::Node
					root_node.children['api'].children['v1'].children['foo'] => Lenna::Node
					root_node.children['api'].children['v1'].children['foo'].children => ::Hash
					root_node
												.children['api']
												.children['v1']
												.children['foo'].children[:placeholder].endpoint['GET'] => ::Proc
				end
			end
		end
	end
end
