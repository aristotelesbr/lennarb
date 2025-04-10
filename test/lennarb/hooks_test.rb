require "test_helper"

class HooksTest < Minitest::Test
  test "for initializes hooks for a given app class" do
    mock_app = Class.new
    hooks = Lennarb::Hooks.for(mock_app)
    assert_equal({before: [], after: []}, hooks)
  end

  test "add adds a valid before hook" do
    mock_app = Class.new
    hooks = Lennarb::Hooks
    hook = ->(req, res) { res.headers["X-Test"] = "value" }
    hooks.add(mock_app, :before, &hook)
    assert_includes hooks.for(mock_app)[:before], hook
  end

  test "add adds a valid after hook" do
    mock_app = Class.new
    hooks = Lennarb::Hooks
    hook = ->(req, res) { res.body << "done" }
    hooks.add(mock_app, :after, &hook)
    assert_includes hooks.for(mock_app)[:after], hook
  end

  test "add raises an error for invalid hook type" do
    mock_app = Class.new
    hooks = Lennarb::Hooks
    assert_raises(ArgumentError) { hooks.add(mock_app, :invalid) }
  end

  test "execute runs all before hooks in order" do
    mock_app = Class.new
    hooks = Lennarb::Hooks
    req = Object.new
    res = Struct.new(:headers).new({})
    context = Object.new

    hooks.add(mock_app, :before) { |req, res| res.headers[:hook1] = "value1" }
    hooks.add(mock_app, :before) { |req, res| res.headers[:hook2] = "value2" }

    hooks.execute(context, mock_app, :before, req, res)
    assert_equal "value1", res.headers[:hook1]
    assert_equal "value2", res.headers[:hook2]
  end

  test "execute runs all after hooks in order" do
    mock_app = Class.new
    hooks = Lennarb::Hooks
    req = Object.new
    res = Struct.new(:body).new([])
    context = Object.new

    hooks.add(mock_app, :after) { |req, res| res.body << "hook1 " }
    hooks.add(mock_app, :after) { |req, res| res.body << "hook2" }

    hooks.execute(context, mock_app, :after, req, res)
    assert_equal "hook1 hook2", res.body.join
  end
end
