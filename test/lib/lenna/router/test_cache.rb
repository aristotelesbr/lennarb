# frozen_string_literal: true

require 'test_helper'

module Lenna
  class Router
    class TestCache < Minitest::Test
      def setup
        @cache = Cache.new
      end

      def test_cache
        assert_nil @cache.get(:foo)
      end

      def test_add_and_get
        root_node = Node.new({}, nil)

        cache_key = @cache.cache_key('GET', '/')
        @cache.add(cache_key, root_node)

        assert_equal @cache.get(cache_key), root_node
      end

      def test_when_does_not_exist
        refute @cache.exist?(:foo)
      end

      def test_when_exist
        root_node = Node.new({}, nil)

        cache_key = @cache.cache_key('GET', '/')
        @cache.add(cache_key, root_node)

        assert @cache.exist?(cache_key)
      end
    end
  end
end
