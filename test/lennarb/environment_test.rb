require "test_helper"

class EnvironmentTest < Minitest::Test
  test "returns name" do
    env = Lennarb::Environment.new("development")

    assert_equal :development, env.name
  end

  test "detects development environment" do
    env = Lennarb::Environment.new("development")

    assert env.development?
    assert env.local?
  end

  test "detects test environment" do
    env = Lennarb::Environment.new("test")

    assert env.test?
    assert env.local?
  end

  test "detects production environment" do
    env = Lennarb::Environment.new("production")

    assert env.production?
    refute env.local?
  end

  test "implements equality" do
    env = Lennarb::Environment.new("development")

    assert_operator env, :==, :development
    assert_operator env, :==, "development"
  end

  test "converts to symbol" do
    env = Lennarb::Environment.new("development")

    assert_equal :development, env.to_sym
  end

  test "converts to string" do
    env = Lennarb::Environment.new("development")

    assert_equal "development", env.to_s
  end

  test "inspects instance" do
    env = Lennarb::Environment.new("development")

    assert_equal %("development"), env.inspect
  end

  test "runs hook when matching environment" do
    env = Lennarb::Environment.new("development")
    called = false

    env.on(:development) { called = true }

    assert called
  end

  test "runs hook when matching local" do
    env = Lennarb::Environment.new("development")
    called = false

    env.on(:local) { called = true }

    assert called
  end

  test "runs hook on all environments" do
    env = Lennarb::Environment.new("development")
    called = false

    env.on(:any) { called = true }

    assert called

    env.on(:all) { called = true }

    assert called
  end

  test "fails with invalid environment" do
    assert_raises ArgumentError do
      Lennarb::Environment.new("invalid")
    end
  end

  test "two environments with the same name are equal" do
    assert_equal Lennarb::Environment.new(:test), Lennarb::Environment.new(:test)
  end

  test "environments with different names are not equal" do
    refute_equal Lennarb::Environment.new(:test), Lennarb::Environment.new(:production)
  end

  test "equal? keeps Ruby's object identity meaning" do
    env = Lennarb::Environment.new(:test)

    assert env.equal?(env)
    refute env.equal?(Lennarb::Environment.new(:test))
    refute env.equal?(:test)
  end

  test "eql? and hash are consistent, so it works as a Hash key" do
    a = Lennarb::Environment.new(:test)
    b = Lennarb::Environment.new(:test)

    assert a.eql?(b)
    assert_equal a.hash, b.hash
    assert_equal 1, {a => 1}[b]
  end
end
