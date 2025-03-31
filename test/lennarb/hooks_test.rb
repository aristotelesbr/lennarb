require "test_helper"

class HooksTest < Minitest::Test
  def setup
    @helpers_module = Module.new do
      def test_helper
        "helper_value"
      end
    end

    @req = {}
    @res = {}
    @hooks = Lennarb::Hooks.new(@helpers_module)
  end

  test "initializes with empty before and after hooks" do
    assert_empty @hooks.before_hooks, "before_hooks should be empty on initialization"
    assert_empty @hooks.after_hooks, "after_hooks should be empty on initialization"
  end

  test "before adds a block to before_hooks" do
    @hooks.before { |req, res| req["before"] = "yes" }
    assert_equal 1, @hooks.before_hooks.size, "before should add one block to before_hooks"
  end

  test "after adds a block to after_hooks" do
    @hooks.after { |req, res| res["after"] = "yes" }
    assert_equal 1, @hooks.after_hooks.size, "after should add one block to after_hooks"
  end

  test "run_before_hooks executes registered before hooks" do
    @hooks.before { |req, res| req["before"] = "executed" }
    @hooks.run_before_hooks(@req, @res)

    assert_equal "executed", @req["before"], "run_before_hooks should execute the before hook"
    assert_nil @res["after"], "run_before_hooks should not affect after hooks"
  end

  test "run_after_hooks executes registered after hooks" do
    @hooks.after { |req, res| res["after"] = "executed" }
    @hooks.run_after_hooks(@req, @res)

    assert_equal "executed", @res["after"], "run_after_hooks should execute the after hook"
    assert_nil @req["before"], "run_after_hooks should not affect before hooks"
  end

  test "hooks have access to helpers" do
    @hooks.before { |req, res| req["helper"] = test_helper }
    @hooks.after { |req, res| res["helper"] = test_helper }

    @hooks.run_before_hooks(@req, @res)
    @hooks.run_after_hooks(@req, @res)

    assert_equal "helper_value", @req["helper"], "before hook should have access to helpers"
    assert_equal "helper_value", @res["helper"], "after hook should have access to helpers"
  end

  test "multiple before hooks execute in order" do
    @hooks.before { |req, res| req["order"] = "first" }
    @hooks.before { |req, res| req["order"] += "-second" }
    @hooks.run_before_hooks(@req, @res)

    assert_equal "first-second", @req["order"], "multiple before hooks should execute in order"
  end

  test "multiple after hooks execute in order" do
    @hooks.after { |req, res| res["order"] = "first" }
    @hooks.after { |req, res| res["order"] += "-second" }
    @hooks.run_after_hooks(@req, @res)

    assert_equal "first-second", @res["order"], "multiple after hooks should execute in order"
  end

  test "no hooks registered does not raise error" do
    assert_silent do
      @hooks.run_before_hooks(@req, @res)
      @hooks.run_after_hooks(@req, @res)
    end
    assert_nil @req["before"], "no before hooks should leave req unchanged"
    assert_nil @res["after"], "no after hooks should leave res unchanged"
  end
end
