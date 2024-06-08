# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

require 'test_helper'

class Lennarb
	class TestPlugin < Minitest::Test
		module SimplePlugin
			module InstanceMethods
				def test_instance_method
					'instance method executed'
				end
			end

			module ClassMethods
				def test_class_method
					'class method executed'
				end
			end
		end

		def setup
			@plugin_name = :test_plugin
			Lennarb::Plugin.register(@plugin_name, SimplePlugin)
		end

		def teardown
			Lennarb::Plugin.plugins.clear
		end

		def test_register_plugin
			assert_equal SimplePlugin, Lennarb::Plugin.plugins[@plugin_name]
		end

		def test_load_plugin
			loaded_plugin = Lennarb::Plugin.load(@plugin_name)

			assert_equal SimplePlugin, loaded_plugin
		end

		def test_load_unregistered_plugin_raises_error
			assert_raises(LennarbError) { Lennarb::Plugin.load(:nonexistent_plugin) }
		end
	end
end
