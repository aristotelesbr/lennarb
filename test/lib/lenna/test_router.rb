# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'test_helper'

module Lenna
	class Router
		class TestRouter < Minitest::Test
			def test_initialize
				router = Router.new

				assert_kind_of TrieNode, router.root_node
			end

			def test_add_namespace
				router    = Router.new
				namespace = '/api'

				router.add_namespace(namespace) do
					router.add_route(::Rack::GET, '/foo') { 'Test Response' }
				end

				method = 'GET'
				path   = '/api/foo'

				block,   = router.find_route(method, path)
				response = block.call if block

				assert_equal 'Test Response', response
			end

			def test_add_route
				router = Router.new

				router.add_route(::Rack::GET, '/foo') { 'Test Response' }

				method = 'GET'
				path   = '/foo'

				block,   = router.find_route(method, path)
				response = block.call if block

				assert_equal 'Test Response', response
			end

			def test_find_route
				router = Router.new

				router.add_route(::Rack::GET,  '/foo') { 'Foo Result' }
				router.add_route(::Rack::POST, '/bar') { 'Bar Result' }

				method = 'POST'
				path   = '/bar'

				block,   = router.find_route(method, path)
				response = block.call if block

				assert_equal 'Bar Result', response
			end
		end
	end
end
