# frozen_string_literal: true

require 'test_helper'

module Lenna
	module Cli
		module Commands
			class TestInterface < Minitest::Test
				include Interface

				def test_new_raises_not_implemented_error
					assert_raises NotImplementedError do
						new([])
					end
				end

				def test_call_raises_not_implemented_error
					assert_raises NotImplementedError do
						call
					end
				end
			end
		end
	end
end
