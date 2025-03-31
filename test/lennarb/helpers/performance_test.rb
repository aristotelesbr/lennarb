require "test_helper"

class HelpersPerformanceTest < Minitest::Test
  include Rack::Test::Methods

  setup do
    @app_class = Class.new(Lennarb::App) do
      helpers do
        50.times do |i|
          define_method(:"helper_#{i}") { "Value #{i}" }
        end
      end

      get "/helpers" do |req, res|
        values = (0..49).map { |i| send(:"helper_#{i}") }.join(", ")
        res.text("Helpers: #{values}")
      end
    end

    @app = @app_class.new
    @app.initialize!
  end

  attr_reader :app

  test "many helpers are accessible without performance degradation" do
    get "/helpers"
    assert_equal 200, last_response.status
    expected = "Helpers: " + (0..49).map { |i| "Value #{i}" }.join(", ")
    assert_equal expected, last_response.body
  end
end
