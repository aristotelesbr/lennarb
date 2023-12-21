# frozen_string_literal: true

require 'test_helper'

class TestLennarb < Minitest::Test
	def test_root
		assert_equal File.expand_path('../..', __dir__), Lennarb.root.to_s
	end
end
