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
      Lennarb::Plugin.registry.clear
    end

    def test_register_plugin
      assert_equal SimplePlugin, Lennarb::Plugin.registry[@plugin_name]
    end

    def test_load_plugin
      loaded_plugin = Lennarb::Plugin.load(@plugin_name)

      assert_equal SimplePlugin, loaded_plugin
    end

    def test_load_unregistered_plugin_raises_error
      assert_raises(Lennarb::Plugin::Error) { Lennarb::Plugin.load(:nonexistent_plugin) }
    end

    def test_load_defaults
      Lennarb::Plugin.load_defaults!

      assert Lennarb::Plugin.instance_variable_get(:@defaults_loaded)
    end

    def test_load_defaults_does_not_reload
      Lennarb::Plugin.load_defaults!
      Lennarb::Plugin.load_defaults!

      assert Lennarb::Plugin.instance_variable_get(:@defaults_loaded)
    end

    def test_load_defaults_environment_variable
      ENV['LENNARB_AUTO_LOAD_DEFAULTS'] = 'false'

      refute_predicate Lennarb::Plugin, :load_defaults?
    ensure
      ENV.delete('LENNARB_AUTO_LOAD_DEFAULTS')
    end
  end
end
