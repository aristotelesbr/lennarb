require "test_helper"

class HelpersTest < Minitest::Test
  class MockApp; end

  module TestHelper
    def test_method
      "test"
    end
  end

  def setup
    @helpers = Lennarb::Helpers
  end

  test "for initializes a helpers module for a given app class" do
    helpers_module = @helpers.for(MockApp)
    assert_instance_of Module, helpers_module
    assert_equal helpers_module, @helpers.for(MockApp)
  end

  test "define includes a module into the helpers module" do
    helpers_module = @helpers.define(MockApp, TestHelper)
    assert_includes helpers_module.instance_methods, :test_method
  end

  test "define evaluates a block in the helpers module" do
    helpers_module = @helpers.define(MockApp) do
      def another_test_method
        "another_test"
      end
    end

    assert_includes helpers_module.instance_methods, :another_test_method
  end

  test "define handles both a module and a block" do
    helpers_module = @helpers.define(MockApp, TestHelper) do
      def foo_helper
        "foo_helper"
      end
    end

    assert_includes helpers_module.instance_methods, :foo_helper
    assert_includes helpers_module.instance_methods, :test_method
  end
end
