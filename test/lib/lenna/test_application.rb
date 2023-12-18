# frozen_string_literal: true

require "test_helper"

class TestCase
  include Lenna::Base
end

module Lenna
  class ApplicationTest < Minitest::Test
    def test_initialize
      assert_instance_of Lenna::Application, Lenna::Application.new
    end

    def test_initialize_with_block
      assert_instance_of Lenna::Application, Lenna::Application.new { |app| app }
    end

    def test_app
      assert_instance_of Lenna::Application, Lenna::Application.app
    end

    def test_app_method_presence
      assert_respond_to TestCase, :app, "The app method should be defined"
    end

    def test_app_with_block
      app_instance = TestCase.app

      assert_instance_of Lenna::Application,
        app_instance,
        "The app method should return an instance of Lenna::Application"
    end
  end
end
