# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'colorize'

module Lenna
	module Middleware
		module Default
			# The Logging module is responsible for logging the requests.
			#
			# @private
			#
			module Logging
				extend self

				# This method is used to log the request.
				#
				# @parameter req             [Rack::Request ] The request
				# @parameter res             [Rack::Response] The response
				# @parameter next_middleware [Proc]           The next middleware
				#
				def call(req, res, next_middleware)
					start_time = ::Time.now
					next_middleware.call
					end_time = ::Time.now

					http_method = colorize_http_method(req.request_method)
					status_code = colorize_status_code(res.status.to_s)
					duration = calculate_duration(start_time, end_time)

					log_message = "[#{start_time}] \"#{http_method} #{req.path_info}\" " \
																			"#{status_code} #{format('%.2f', duration)}ms"

					::Kernel.puts(log_message)
				end

				private

				# This method is used to colorize the request method.
				#
				# @parameter request_method [String] The request method
				#
				# @return                   [String] The colorized request method
				#
				# @private
				#
				def colorize_http_method(request_method)
					case request_method
					in 'GET' then 'GET'.green
					in 'POST' then 'POST'.magenta
					in 'PUT' then 'PUT'.yellow
					in 'DELETE' then 'DELETE'.red
					else request_method.blue
					end
				end

				# This method is used to colorize the status code.
				#
				# @param status_code [String] The status code
				#
				# @return            [String] The colorized status code
				#
				# @private
				#
				def colorize_status_code(status_code)
					case status_code
					in '2' then status_code.green
					in '3' then status_code.blue
					in '4' then status_code.yellow
					in '5' then status_code.red
					else status_code
					end
				end

				# This method is used to calculate the duration.
				#
				# @param start_time [Time] The start time
				#
				# @param end_time   [Time] The end time
				# @return           [Float] The duration
				#
				# @api private
				#
				def calculate_duration(start_time, end_time)
					millis_in_second = 1000.0
					(end_time - start_time) * millis_in_second
				end
			end
		end
	end
end
