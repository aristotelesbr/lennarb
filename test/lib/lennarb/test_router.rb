# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

require 'test_helper'

class Lennarb
	class TestRouterTest < Minitest::Test
		class MyApp
			include Lennarb::Router
		end

		def test_included
			assert_respond_to MyApp, :route
			assert_respond_to MyApp, :app
		end

		def test_ancestors
			assert_includes MyApp.ancestors, Lennarb::Router
		end

		def test_router
			assert_kind_of Lennarb, MyApp.router
		end

		def test_app
			assert_kind_of Lennarb, MyApp.app
		end
	end
end
