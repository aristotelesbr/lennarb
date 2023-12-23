# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'console'

# This middleware is used to reload files in development mode.
#
module Lenna
	module Middleware
		module Default
			class Reload
				attr_accessor :directories, :files_mtime

				# Initializes a new instance of Middleware::Default::Reload.
				#
				# @parameter directories [Array] An array of directories to monitor.
				#
				# @return [Middleware::Default::Reload] A new instance of Middleware::Default::Reload.
				def initialize(directories = [])
					self.files_mtime = {}
					self.directories = directories

					monitor_directories(directories)
				end

				# Calls the middleware.
				#
				# @parameter req             [Rack::Request] The request.
				# @parameter _res            [Rack::Response] The response.
				# @parameter next_middleware [Proc] The next middleware.
				#
				# @return [void]
				#
				def call(_req, _res, next_middleware)
					reload_if_needed

					next_middleware.call
				rescue ::StandardError => error
					::Console.error(self, error)
				end

				private

				# Reloads files if needed.
				#
				# @return [void]
				#
				def reload_if_needed
					modified_files = check_for_modified_files

					reload_files(modified_files) unless modified_files.empty?
				end

				# Monitors directories for changes.
				#
				# @parameter directories [Array] An array of directories to monitor.
				#
				# @return [void]
				#
				def monitor_directories(directories)
					directories.each do |directory|
						::Dir.glob(directory).each { |file| files_mtime[file] = ::File.mtime(file) }
					end
				end

				# Checks for modified files.
				#
				# @return [Array] An array of modified files.
				#
				# @example
				#   check_for_modified_files #=> ["/path/to/file.rb"]
				#
				def check_for_modified_files
					@files_mtime.select do |file, last_mtime|
						::File.mtime(file) > last_mtime
					end.keys
				end

				# Reloads files.
				#
				# @parameter files [Array] An array of files(paths) to reload.
				#
				# @return [void]
				#
				def reload_files(files)
					files.each do |file|
						::Console.debug("Reloading #{file}")
						::Kernel.load file
						@files_mtime[file] = ::File.mtime(file)
					end
				end
			end
		end
	end
end
