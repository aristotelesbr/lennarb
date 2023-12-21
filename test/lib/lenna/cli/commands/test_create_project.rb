# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'fileutils'
require 'lenna/cli/commands/create_project'
require 'test_helper'

module Lenna
	module Cli
		module Commands
			class TestCreateProject < Minitest::Test
				def setup
					@app_name = 'test_app'
					FileUtils.mkdir_p(@app_name)

					Commands::CreateProject.execute(@app_name)
				end

				def test_create_gemfile
					@gemfile_content = <<-GEMFILE
						# frozen_string_literal: true

						source 'https://rubygems.org'

						# [https://rubygems.org/gems/lennarb]
						# Lenna is a lightweight and experimental web framework for Ruby. It's designed
						# to be modular and easy to use. Also, that's how I affectionately call my wife.
						gem 'lennarb', '~> 0.1.7'
						# [https://rubygems.org/gems/falcon]
						# A fast, asynchronous, rack-compatible web server.
						gem 'falcon', '~> 0.42.3'

						group :development, :test do
						end
					GEMFILE

					# gemfile_path = File.join(Lennarb::ROOT_PATH, @app_name, 'Gemfile')
					gemfile_path = Lennarb.root.join(@app_name, 'Gemfile')

					assert_path_exists gemfile_path

					actual_content = File.read(gemfile_path).gsub(/\s+/, ' ').strip
					expected_content = @gemfile_content.gsub(/\s+/, ' ').strip

					assert_equal expected_content, actual_content
				end

				def teardown
					FileUtils.rm_rf(Lennarb.root.join(@app_name))
				end
			end
		end
	end
end
