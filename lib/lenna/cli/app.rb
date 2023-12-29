# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

module Lenna
	module Cli
		# Mediator class for CLI
		#
		# @private `Since v0.1.0`
		#
		module App
			extend self
			# Execute the command
			#
			# @return [void]
			#
			def run!(args)
				subcommand = args.shift

				strategy = parse_options(subcommand, args)

				strategy.is_a?(Lenna::Cli::Commands::Interface) or fail ::ArgumentError

				strategy.call
			end

			private

			def parse_options(command, args)
				case command
				in 'new'    | 'start' then Lenna::Cli::Commands::CreateProject.new(args)
				in 'server' | 's'     then Lenna::Cli::Commands::StartServer.new(args)
				else 'help'
				end
			end
		end
	end
end
