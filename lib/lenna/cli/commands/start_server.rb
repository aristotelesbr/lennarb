# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'console'
require 'optparse'

module Lenna
	module Cli
		module Commands
			# Command for creating a new app
			#
			# @private `Since v0.1.0`
			#
			class StartServer
				include Lenna::Cli::Commands::Interface

				# @!attribute [rw] port
				#   @return [Integer] Port to start the server
				#
				private attr_accessor :port
				# @!attribute [rw] server
				#   @return [String] Server to start
				#
				private attr_accessor :server
				# @!attribute [rw] command
				#   @return [String] Command to execute
				#
				private attr_accessor :command

				def initialize(args)
					self.command = args.shift

					options = parse_options!(args)

					self.port   = options[:port]
					self.server = options[:server]
				end

				# Execute the command
				#
				# @return [void]
				#
				def call
					::Console.debug("Starting server on port #{port}...")

					case server
					in 'puma' | 'falcon' => server then start_server(port:, server:)
					else fail ::ArgumentError, ::Console.error("The server '#{server}' is not supported yet.")
					end
				end

				private

				# Parse the options
				#
				# @parameter args [Array<String>] The arguments
				#
				# @return [Hash] The options
				#
				def parse_options!(args)
					options = { port: 4000, server: 'puma' }

					::OptionParser.new do |opts|
						opts.banner = "Usage: lenna #{command} [options]"

						opts.on('-p', '--port [PORT]', Integer, 'Port to start the server') do |port|
							options[:port] = port
						end

						opts.on('-s', '--server [SERVER]', String, 'Server to start') do |server|
							options[:server] = server
						end
					end.parse!(args)

					options
				end

				# Start the server
				#
				# @paramaeter port   [Integer] Port to start the server
				# @paramaeter server [String] Server to start
				#
				# @return [void]
				#
				def start_server(port:, server:)
					return warn_not_installed(server) unless instaled_gem?(server)

					::File.exist?(config_file) or fail ::StandardError, ::Console.error("'config.ru' not found in #{poroject_name}.")

					system("bundle exec #{server} #{config_file} --port #{port}", chdir: current_path)
				rescue ::ArgumentError
					::Console.error("The server '#{server}' is not supported yet.")
				rescue ::Interrupt
					::Console.info("\nServer stopped.")
				rescue ::StandardError => e
					::Console.error(self, e.message)
				end

				# Check if the gem is installed
				#
				# @parameter name [String] Name of the gem
				#
				# @return [Boolean]
				#
				def instaled_gem?(name)
					::Gem::Specification.find_by_name(name)
				rescue ::Gem::LoadError
					false
				end

				# Get the name of the project
				#
				# @return [String] Name of the project
				#
				def poroject_name = @current_path.split('/').last

				# Get the path of the project
				#
				# @return [String] Path of the project
				#
				def current_path = @current_path ||= ::Dir.pwd

				# Get the path of the config file
				#
				# @return [String] Path of the config file
				#
				def config_file = "#{current_path}/config.ru"

				# Warn the user that the gem is not installed
				#
				# @parameter name [String] Name of the gem
				#
				# @return [void]
				#
				def warn_not_installed(name)
					::Console.warn("The gem '#{name}' is not installed. Please install it and try again.")
				end
			end
		end
	end
end
