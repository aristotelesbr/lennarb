require "test_helper"

class HookableTest < Minitest::Test
  test "hooks can be defined" do
    klass = Class.new do
      include Lennarb::Hooks::Hookable
    end

    assert_respond_to klass, :before
    assert_respond_to klass, :after
  end
end
