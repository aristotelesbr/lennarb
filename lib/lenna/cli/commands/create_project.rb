# frozen_string_literal: true

require 'colorize'
require 'erb'
require 'fileutils'
require 'lenna/cli/commands/interface'
require 'lennarb/version'

module Lenna
	module Cli
		module Commands
			# Command for creating a new app
			#
			# @private `Since v0.1.0`
			#
			module CreateProject
				extend Lenna::Cli::Commands::Interface, self
				# Execute the command
				#
				# @parameter app_name [String] The name of the app
				#
				# @return [void]
				#
				def execute(app_name)
					return puts 'Please specify an app name' if app_name.nil?

					puts "Creating a new app named #{app_name}".green
					create_app(app_name)
					create_gemfile(app_name)
				end

				private

				# Create a directory for the app
				#
				# @parameter app_name [String] The name of the app
				#
				# @return [void]
				#
				def create_app(app_name) = FileUtils.mkdir_p(app_name)

				# Create a new Gemfile for the app. This will be use template
				# file in the `templates` directory.
				#
				# @parameter app_name [String] The name of the app
				#
				# @return [void]
				#
				def create_gemfile(app_name)
					FileUtils.cd(app_name).tap do
						template_data = { version: Lennarb::VERSION }

						erb_template =
							Lennarb.root.join('lib/lenna/cli/templates/gemfile.erb')
							.then { File.read(_1) }
							.then { ERB.new(_1) }

						File.write('Gemfile', erb_template.result_with_hash(template_data))
					end
				end
			end
		end
	end
end
