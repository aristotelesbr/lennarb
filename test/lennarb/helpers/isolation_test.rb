class HelpersIsolationTest < Minitest::Test
  include Rack::Test::Methods

  FooApp = Class.new(Lennarb::App) do
    helpers do
      def current_user
        "Foo User"
      end
    end

    get "/user" do |req, res|
      res.text("Hello, #{current_user}")
    end
  end

  BarApp = Class.new(Lennarb::App) do
    helpers do
      def current_user
        "Bar User"
      end
    end

    get "/user" do |req, res|
      res.text("Hello, #{current_user}")
    end
  end

  setup do
    @root_app = Class.new(Lennarb::Base) do
      mount FooApp, at: "/foo"
      mount BarApp, at: "/bar"
    end.new.tap(&:initialize!)
  end

  def app
    @root_app
  end

  test "helpers are isolated between mounted apps" do
    get "/foo/user"
    assert_equal 200, last_response.status
    assert_equal "Hello, Foo User", last_response.body

    get "/bar/user"
    assert_equal 200, last_response.status
    assert_equal "Hello, Bar User", last_response.body
  end

  test "unmounted path returns 404" do
    get "/baz/user"
    assert_equal 404, last_response.status
  end
end
