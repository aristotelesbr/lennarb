# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'optparse'

require 'lenna/cli/commands/interface'
require 'lennarb/version'

module Lenna
	module Cli
		# Mediator class for CLI
		#
		# @private `Since v0.1.0`
		#
		class App
			# @return [Array] Arguments passed to CLI
			#
			attr_reader :args

			# Initialize a new instance of the class
			#
			# @parameter args [Array] Arguments passed to CLI
			#
			def initialize(args)
				@args = args
			end

			# Execute the command
			#
			# @return [void]
			#
			def execute(strategy)
				strategy.is_a?(Lenna::Cli::Commands::Interface) or fail ::ArgumentError

				parser!(@args).then { strategy.execute(_1) }
			end

			private

			# Parse the options passed to CLI
			#
			# @parameter args [Array] Arguments passed to CLI
			#
			# @return [Hash] Options passed to CLI
			#
			def parser!(args)
				options = {}
				OptionParser.new do |opts|
					opts.banner = 'Usage: lenna [options]'

					opts.on('-v', '--version', 'Print version') do
						puts Lenna::VERSION
						exit
					end

					opts.on('-h', '--help', 'Print help') do
						puts opts
						exit
					end

					opts.on('-n', '--new', 'Create a new app') do
						options[:port] = 3000
						options[:server] = 'puma'
					end

					opts.on('-s', '--start', 'Start the server') do
						options[:start] = true
					end
				end.parse!(args)

				options
			end
		end
	end
end
