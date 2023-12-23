# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

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
					return puts 'Please specify an app name'.red if app_name.nil?

					create_app(app_name) do
						create_gemfile
						create_config_ru
						create_app_directory
					end
				end

				private

				# Create a directory for the app
				#
				# @parameter app_name [String] The name of the app
				#
				# @yield { ... } The block to be executed after the directory
				#
				# @return [void]
				#
				def create_app(app_name)
					puts "Creating a new app named #{app_name}".green

					::FileUtils.mkdir_p(app_name)

					::FileUtils.cd(app_name).tap { yield app_name } if block_given?

					app_name
				end

				# Create a new Gemfile for the app. This will be use template
				# file in the `templates` directory.
				#
				# @parameter app_name [String] The name of the app
				#
				# @return [void]
				#
				def create_gemfile
					{ version: Lennarb::VERSION }.then { create_template('gemfile', _1, 'Gemfile') }
				end

				# Create a new config.ru for the app. This will be use template
				# file in the `templates` directory.
				#
				# @return [void]
				#
				def create_config_ru
					create_template('config.ru', {})
				end

				# Create a new application.rb for the app. This will be use template
				# file in the `templates` directory.
				#
				# @return [void]
				#
				# @See #create_template
				# @See lenna/cli/templates/application
				#
				def create_app_directory
					create_template('application', {}, 'app/application.rb')
				end

				# Method for creating file based on a template
				#
				# @parameter template_name [String] The name of the template
				# @parameter template_data [Hash] The data to be used in the template
				#
				# @return [void]
				#
				def create_template(template_name, template_data, file_name = template_name)
					Lennarb # rubocop:disable Lint
						.root
						.join("lib/lenna/cli/templates/#{template_name}.erb")
						.then { ::File.read(_1) }
						.then { ::ERB.new(_1)   }
						.then { result_with_hash(template_data) }
						.then { ::File.write(file_name, _1) }
				end
			end
		end
	end
end
