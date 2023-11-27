# frozen_string_literal: true

require 'colorize'

module Lenna
  module Middleware
    module Default
      # The Logging module is responsible for logging the requests.
      #
      # @api private
      #
      # @example:
      #   Logging.call(req, res, next_middleware)
      #  # => [2021-01-01 00:00:00 +0000] "GET /" 200 0.00ms
      #
      module Logging
        extend self

        # This method is used to log the request.
        #
        # @param req             [Rack::Request ] The request
        # @param res             [Rack::Response] The response
        # @param next_middleware [Proc]           The next middleware
        #
        def call(req, res, next_middleware)
          start_time = ::Time.now
          next_middleware.call
          end_time = ::Time.now

          http_method = colorize_http_method(req.request_method)
          status_code = colorize_status_code(res.status.to_s)
          duration    = calculate_duration(start_time, end_time)

          log_message = "[#{start_time}] \"#{http_method} #{req.path_info}\" " \
                        "#{status_code} #{format('%.2f', duration)}ms"

          ::Kernel.puts(log_message)
        end

        private

        # This method is used to colorize the request method.
        #
        # @param request_method [String] The request method
        # @return               [String] The colorized request method
        #
        # @api private
        #
        # @example:
        #   colorize_http_method('GET') # => 'GET'.green
        #
        def colorize_http_method(request_method)
          case request_method
          in 'GET'    then 'GET'.green
          in 'POST'   then 'POST'.magenta
          in 'PUT'    then 'PUT'.yellow
          in 'DELETE' then 'DELETE'.red
          else request_method.blue
          end
        end

        # This method is used to colorize the status code.
        #
        # @param status_code [String] The status code
        # @return            [String] The colorized status code
        #
        # @api private
        #
        # @example:
        #   colorize_status_code('200') # => '200'.green
        #
        def colorize_status_code(status_code)
          case status_code[0]
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
        # @param end_time   [Time] The end time
        # @return           [Float] The duration
        #
        # @api private
        #
        # @example:
        #   calculate_duration(Time.now, Time.now + 1) # => 1000
        #
        def calculate_duration(start_time, end_time)
          millis_in_second = 1000.0
          (end_time - start_time) * millis_in_second
        end
      end
    end
  end
end
