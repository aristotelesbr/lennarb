require "test_helper"

class RoutingTest < Minitest::Test
  test "routes can be defined" do
    klass = Class.new do
      include Lennarb::Routing
    end

    assert_respond_to klass, :routes
    assert_instance_of Lennarb::Routes, klass.routes
  end

  test "HTTP methods are defined" do
    klass = Class.new do
      include Lennarb::Routing
    end

    Lennarb::HTTP_METHODS.each do |method|
      assert_respond_to klass, method.downcase.to_sym
    end
  end
end
