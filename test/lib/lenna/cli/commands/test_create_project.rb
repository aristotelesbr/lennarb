# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'fileutils'
require 'test_helper'

module Lenna
	module Cli
		module Commands
			class TestCreateProject < Minitest::Test
				def setup
					@app_name = 'test_app'
					input = [@app_name]
					FileUtils.mkdir_p(@app_name)

					Commands::CreateProject.new(input).call
				end

				def test_create_gemfile
					@gemfile_content = <<-GEMFILE
						# frozen_string_literal: true

						source 'https://rubygems.org'

						# [https://rubygems.org/gems/lennarb]
						# Lenna is a lightweight and experimental web framework for Ruby. It's designed
						# to be modular and easy to use. Also, that's how I affectionately call my wife.
						gem 'lennarb', '~> #{Lennarb::VERSION}'
						# [https://rubygems.org/gems/puma]
						# Puma is a simple, fast, threaded, and highly parallel HTTP 1.1 server for Ruby/Rack applications.
						gem 'puma', '~> 6.4'

						group :development, :test do
						end
					GEMFILE

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
