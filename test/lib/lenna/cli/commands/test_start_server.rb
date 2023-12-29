# frozen_string_literal: true

require 'test_helper'

module Lenna
	module Cli
		module Commands
			class TestStartServer < ::Minitest::Test
				def test_execute_with_invalid_server
					input = %w[server -p 3000 -s invalid]

					assert_raises(::ArgumentError) { Commands::StartServer.new(input).call }
				end
			end
		end
	end
end
