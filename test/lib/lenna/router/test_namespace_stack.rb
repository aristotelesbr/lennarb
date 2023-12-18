# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require "test_helper"

module Lenna
  class Router
    class TestNamespaceStack < Minitest::Test
      def setup
        @stack = NamespaceStack.new
      end

      def test_push
        @stack.push("/api")
        @stack.push("/v1")
        @stack.push("/lenna-router")

        assert_equal "/api/v1/lenna-router", @stack.to_s
      end

      def test_pop
        @stack.push("/api")
        @stack.push("/v1")
        @stack.push("/lenna-router")

        @stack.pop

        assert_equal "/api/v1", @stack.to_s

        @stack.pop

        assert_equal "/api", @stack.to_s

        @stack.pop

        assert_equal "", @stack.to_s
      end

      def test_current_prefix
        @stack.push("/api")
        @stack.push("/v1")
        @stack.push("/lenna-router")

        assert_equal "/api/v1/lenna-router", @stack.current_prefix
      end

      def test_to_s_with_empty_stack
        assert_equal "", @stack.to_s
      end

      def test_to_s_with_one_element_stack
        @stack.push("/api")

        assert_equal "/api", @stack.to_s
      end
    end
  end
end
