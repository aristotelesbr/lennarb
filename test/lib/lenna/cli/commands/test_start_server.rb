# frozen_string_literal: true

require 'test_helper'

require 'lenna/cli/commands/start_server'

module Lenna
	module Cli
		module Commands
			class TestStartServer < ::Minitest::Test
				def test_execute_with_invalid_server
					input = { port: 4000, server: 'invalid_driver' }

					assert_raises(::ArgumentError) { Commands::StartServer.execute(input) }
				end
			end
		end
	end
end
