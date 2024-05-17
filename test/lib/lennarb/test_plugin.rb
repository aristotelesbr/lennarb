# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

require 'test_helper'

class Lennarb
	class TestPlugin < Minitest::Test
		def setup
			@plugin_name = :test_plugin
			@plugin_module = Module.new do
				def test_method
					"test"
				end
			end

			Lennarb::Plugin.register(@plugin_name, @plugin_module)
		end

		def teardown
			Lennarb::Plugin.plugins.clear
		end

		def test_register_plugin
			assert_equal @plugin_module, Lennarb::Plugin.plugins[@plugin_name]
		end

		def test_load_plugin
			loaded_plugin = Lennarb::Plugin.load(@plugin_name)
			assert_equal @plugin_module, loaded_plugin
		end

		def test_load_unregistered_plugin_raises_error
			assert_raises(RuntimeError) { Lennarb::Plugin.load(:nonexistent_plugin) }
		end
	end
end
