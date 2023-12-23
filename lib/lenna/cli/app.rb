# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'optparse'

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
				strategy.is_a?(Commands::Interface) or fail ::ArgumentError

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
						options[:new] = true
					end
				end.parser!(args)

				options
			end
		end
	end
end
