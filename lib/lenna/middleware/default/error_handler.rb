# frozen_string_literal: true

require 'cgi'

module Lenna
  module Middleware
    module Default
      # This middleware will handle errors.
      module ErrorHandler
        extend self

        # This method will be called by the server.
        #
        # @param req [Rack::Request] The request object
        # @param res [Rack::Response] The response object
        # @param next_middleware [Proc] The next middleware in the stack
        # @return [void]
        #
        # @api private
        #
        def call(req, res, next_middleware)
          next_middleware.call
        rescue StandardError => e
          env = req.env
          log_error(env, e)

          render_error_page(e, env, req, res)
        end

        private

        # This method will render the error page.
        #
        # @param error [StandardError] The error object
        # @param env [Hash] The environment variables
        # @param res [Rack::Response] The response object
        # @return [void]
        #
        # @api private
        def render_error_page(error, env, req, res)
          case req.headers['Content-Type']
          in 'application/json' then render_json(error, env, res)
          else                       render_html(error, env, res)
          end
        end

        # This method will render the JSON error page.
        #
        # @param error [StandardError] The error object
        # @param env [Hash] The environment variables
        # @param res [Rack::Response] The response object
        # @return [void]
        #
        # @api private
        def render_json(error, env, res)
          case env['RACK_ENV']
          in 'development' | 'test' then res.json(
            data: {
              error: error.message,
              status: 500
            }
          )
          else res.json(error: 'Internal Server Error', status: 500)
          end
        end

        # This method will render the HTML error page.
        #
        # @param error [StandardError] The error object
        # @param env [Hash] The environment variables
        # @param res [Rack::Response] The response object
        # @return [void]
        #
        # @api private
        def render_html(error, env, res)
          res.html(error_page(error, env), status: 500)
        end

        # This method will log the error.
        #
        # @param env [Hash] The environment variables
        # @param error [StandardError] The error object
        # @return [void]
        #
        # @api private
        def log_error(env, error)
          env['rack.errors'].puts error.message
          env['rack.errors'].puts error.backtrace.join("\n")
          env['rack.errors'].flush
        end

        # This method will render the error page.
        def error_page(error, env)
          style = <<-STYLE
          <style>
            body { font-family: 'Helvetica Neue', sans-serif; background-color: #F7F7F7; color: #333; margin: 0; padding: 0; }
            .error-container { max-width: 600px; margin: 20px auto; padding: 20px; box-shadow: 0 4px 8px 0 rgba(0,0,0,0.1); background: white; border-radius: 4px; }
            h1 { color: #c0392b }
            h2 { padding: 0; margin: 0; font-size: 1.2em; }
            .error-details, .backtrace { text-align: left; }
            .error-details strong { color: #e74c3c; }
            pre { background: #ecf0f1; padding: 15px; overflow: auto; border-left: 5px solid #e74c3c; font-size: 0.9em; }
            .backtrace { margin-top: 20px; }
            .backtrace pre { border-color: #3498db; }
            svg { fill: #e74c3c; width: 50px; height: auto; }
            .container { display: flex; justify-content: space-between; align-items: center; align-content: center;}
          </style>
          STYLE

          # SVG logo
          svg_logo = <<~SVG
                  <svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" width="100" height="100" viewBox="0 0 100 100">
            <path fill="#f1bc19" d="M77 12A1 1 0 1 0 77 14A1 1 0 1 0 77 12Z"></path><path fill="#e4e4f9" d="M50 13A37 37 0 1 0 50 87A37 37 0 1 0 50 13Z"></path><path fill="#f1bc19" d="M83 11A4 4 0 1 0 83 19A4 4 0 1 0 83 11Z"></path><path fill="#8889b9" d="M87 22A2 2 0 1 0 87 26A2 2 0 1 0 87 22Z"></path><path fill="#fbcd59" d="M81 74A2 2 0 1 0 81 78 2 2 0 1 0 81 74zM15 59A4 4 0 1 0 15 67 4 4 0 1 0 15 59z"></path><path fill="#8889b9" d="M25 85A2 2 0 1 0 25 89A2 2 0 1 0 25 85Z"></path><path fill="#fff" d="M18.5 49A2.5 2.5 0 1 0 18.5 54 2.5 2.5 0 1 0 18.5 49zM79.5 32A1.5 1.5 0 1 0 79.5 35 1.5 1.5 0 1 0 79.5 32z"></path><g><path fill="#fdfcee" d="M50 25.599999999999998A24.3 24.3 0 1 0 50 74.2A24.3 24.3 0 1 0 50 25.599999999999998Z"></path><path fill="#472b29" d="M50,74.8c-13.8,0-25-11.2-25-25c0-13.8,11.2-25,25-25c13.8,0,25,11.2,25,25C75,63.6,63.8,74.8,50,74.8z M50,26.3c-13,0-23.5,10.6-23.5,23.5S37,73.4,50,73.4s23.5-10.6,23.5-23.5S63,26.3,50,26.3z"></path></g><g><path fill="#ea5167" d="M49.9 29.6A20.4 20.4 0 1 0 49.9 70.4A20.4 20.4 0 1 0 49.9 29.6Z"></path></g><g><path fill="#ef7d99" d="M50.2,32.9c10.6,0,19.3,8.2,20.1,18.5c0-0.5,0.1-1,0.1-1.5c0-11-9-20-20.2-20c-11.1,0-20.2,9-20.2,20 c0,0.5,0,1,0.1,1.5C30.9,41,39.5,32.9,50.2,32.9z"></path></g><g><path fill="#472b29" d="M69.4,44.6c-0.2,0-0.4-0.1-0.5-0.4c-0.1-0.3-0.2-0.6-0.3-0.9c-0.4-1.1-0.9-2.2-1.5-3.2 c-0.1-0.2-0.1-0.5,0.2-0.7c0.2-0.1,0.5-0.1,0.7,0.2c0.6,1.1,1.1,2.2,1.5,3.3c0.1,0.3,0.2,0.6,0.3,0.9c0.1,0.3-0.1,0.5-0.3,0.6 C69.5,44.6,69.5,44.6,69.4,44.6z"></path></g><g><path fill="#472b29" d="M50,70.8c-11.5,0-20.9-9.3-20.9-20.8c0-11.5,9.4-20.8,20.9-20.8c6,0,11.7,2.6,15.6,7c0.3,0.3,0.6,0.7,0.9,1 c0.2,0.2,0.1,0.5-0.1,0.7c-0.2,0.2-0.5,0.1-0.7-0.1c-0.3-0.3-0.5-0.7-0.8-1c-3.8-4.2-9.2-6.7-14.9-6.7c-11,0-19.9,8.9-19.9,19.8 c0,10.9,8.9,19.8,19.9,19.8s19.9-8.9,19.9-19.8c0-1-0.1-2-0.2-3c0-0.3,0.1-0.5,0.4-0.6c0.3,0,0.5,0.1,0.6,0.4 c0.2,1,0.2,2.1,0.2,3.1C70.9,61.4,61.5,70.8,50,70.8z"></path></g><g><path fill="#fdfcee" d="M56,57.1c-0.3,0-0.6-0.1-0.9-0.4l-5.2-5.2l-5.2,5.2c-0.2,0.2-0.5,0.4-0.9,0.4s-0.6-0.1-0.9-0.4 c-0.5-0.5-0.5-1.2,0-1.7l5.2-5.2L43,44.6c-0.5-0.5-0.5-1.2,0-1.7c0.2-0.2,0.5-0.4,0.9-0.4s0.6,0.1,0.9,0.4l5.2,5.2l5.2-5.2 c0.2-0.2,0.5-0.4,0.9-0.4c0.3,0,0.6,0.1,0.9,0.4s0.4,0.5,0.4,0.9s-0.1,0.6-0.4,0.9l-5.2,5.2l5.2,5.2c0.2,0.2,0.4,0.5,0.4,0.9 c0,0.3-0.1,0.6-0.4,0.9S56.3,57.1,56,57.1z"></path><path fill="#472b29" d="M56,43.1c0.2,0,0.4,0.1,0.5,0.2c0.3,0.3,0.3,0.7,0,1l-5.5,5.5l5.5,5.5c0.3,0.3,0.3,0.7,0,1 c-0.1,0.1-0.3,0.2-0.5,0.2s-0.4-0.1-0.5-0.2l-5.5-5.5l-5.5,5.5c-0.1,0.1-0.3,0.2-0.5,0.2s-0.4-0.1-0.5-0.2c-0.3-0.3-0.3-0.7,0-1 l5.5-5.5l-5.5-5.5c-0.3-0.3-0.3-0.7,0-1c0.1-0.1,0.3-0.2,0.5-0.2s0.4,0.1,0.5,0.2l5.5,5.5l5.5-5.5C55.6,43.1,55.8,43.1,56,43.1 M56,42.1c-0.5,0-0.9,0.2-1.2,0.5l-4.8,4.8l-4.8-4.8c-0.3-0.3-0.8-0.5-1.2-0.5s-0.9,0.2-1.2,0.5c-0.3,0.3-0.5,0.8-0.5,1.2 s0.2,0.9,0.5,1.2l4.8,4.8l-4.8,4.8c-0.3,0.3-0.5,0.8-0.5,1.2s0.2,0.9,0.5,1.2c0.3,0.3,0.8,0.5,1.2,0.5s0.9-0.2,1.2-0.5l4.8-4.8 l4.8,4.8c0.3,0.3,0.8,0.5,1.2,0.5s0.9-0.2,1.2-0.5c0.3-0.3,0.5-0.8,0.5-1.2s-0.2-0.9-0.5-1.2l-4.8-4.8l4.8-4.8 c0.3-0.3,0.5-0.8,0.5-1.2s-0.2-0.9-0.5-1.2C56.9,42.2,56.4,42.1,56,42.1L56,42.1z"></path></g>
            </svg>
            #{'    '}
          SVG

          # HTML page
          <<-HTML
          <!DOCTYPE html>
          <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
          #{' '}
            <title>System Error</title>
            #{style}
          </head>
          <body>
            <div class="error-container">
              <div class="container">
                <div class="item-left">
                  <h1>Oops! An error has occurred.</h1>
                </div>
                <div class="item-right">#{svg_logo}</div>
              </div>
          #{'    '}
              #{error_message_and_backtrace(error, env)}
            </div>
          </body>
          </html>
          HTML
        end

        # This method will render the error message and backtrace.
        #
        # @param error [StandardError] The error object
        # @param env [Hash] The environment variables
        # @return [String] The HTML string
        #
        # @api private
        def error_message_and_backtrace(error, env)
          if env['RACK_ENV'] == 'development'
            truncated_message =
              error.message[0..500] + (error.message.length > 500 ? '...' : '')

            file, line = error.backtrace.first.split(':')
            line_number = Integer(line)
            <<-DETAILS
                <div class="error-details">
                  <h2>Error Details:</h2>
                  <p>
                    <strong>Message:</strong> <span id="error-message">#{CGI.escapeHTML(truncated_message)}</span>
                  </p>
                  <div>
                    <p><strong>Location:</strong> #{CGI.escapeHTML(file)}:#{line_number}</p>
                    <pre>#{extract_source(file, line_number)}</pre>
                  </div>

                  <details>
                    <summary>Details</summary>
                    <p id="full-message" style="display: none;">
                      <h3>Full Backtrace:</h3>
                      <p><strong>Full Message:</strong> #{CGI.escapeHTML(error.message)}</p>
                      <pre>#{error.backtrace.join("\n")}</pre>
                    </p>
                  </details>
                </div>
            DETAILS
          else
            "<p>We're sorry, but something went wrong. We've been notified " \
              'about this issue and will take a look at it shortly.</p>'
          end
        end

        # This method will extract the source code.
        #
        # @param file [String] The file path
        # @param line_number [Integer] The line number
        # @return [String] The HTML string
        #
        # @api private
        #
        # @example:
        #   extract_source('/path/to/file.rb', 10)
        #   # => "<strong style='color: red;'>    7: </strong> =>
        #         def foo\n<strong style='color: red;'>    8: </strong>
        #         puts 'bar'\n<strong style='color: red;'>    9: </strong>
        #         end\n<strong style='color: red;'>   10: </strong> foo\n<strong
        #         style='color: red;'>   11: </strong> "
        def extract_source(file, line_number)
          lines = ::File.readlines(file)
          start_line = [line_number - 3, 0].max
          end_line   = [line_number + 3, lines.size].min

          line_ranger = lines[start_line...end_line]

          format_lines(line_ranger, line_number).join
        end

        # This method will format the lines.
        #
        # @api private
        #
        # @example:
        #   format_lines(line_ranger, line_number)
        #   # => ["<strong style='color: red;'>    7: </strong> =>\n",
        #         "<strong style='color: red;'>    8: </strong> puts 'bar'\n",
        #         "<strong style='color: red;'>    9: </strong> end\n",
        #         "<strong style='color: red;'>   10: </strong> foo\n",
        #         "<strong style='color: red;'>   11: </strong> "]
        def format_lines(lines, highlight_line)
          lines.map.with_index(highlight_line - 3 + 1) do |line, line_num|
            line_number_text = "#{line_num.to_s.rjust(6)}: "
            formatted_line = ::CGI.escapeHTML(line)

            if line_num == highlight_line
              "<strong style='color: red;'>#{line_number_text}</strong> " \
                "#{formatted_line}"
            else
              "#{line_number_text}#{formatted_line}"
            end
          end
        end
      end
    end
  end
end
