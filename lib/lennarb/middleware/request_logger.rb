module Lennarb
  module Middleware
    # Request logger for the Lennarb framework
    # Logs HTTP request details with color formatting
    #
    # @example Output:
    #   GET /users/123 (30ms)
    #   Status: 200 OK
    #   Params: {"id"=>"123", "password"=>"[FILTERED]"}
    #
    class RequestLogger
      def initialize(app)
        @app = app
      end

      # Get logger from application configuration
      def logger = Lennarb::App.app.config.logger

      # Process the request and log information
      #
      # @param [Hash] env Rack environment
      # @return [Array] Rack response [status, headers, body]
      def call(env)
        request = Lennarb::Request.new(env)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        status, headers, body = @app.call(env)

        duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

        log_request(request, status, headers, duration)

        [status, headers, body]
      end

      private

      # Format duration in a human-readable way
      #
      # @param [Float] seconds Duration in seconds
      # @return [String] Formatted duration
      def format_duration(seconds)
        if seconds < 1
          "#{(seconds * 1000).round}ms"
        elsif seconds < 60
          format("%.2fs", seconds)
        else
          minutes = (seconds / 60).to_i
          seconds = (seconds % 60).round
          "#{minutes}m #{seconds}s"
        end
      end

      # Log the complete request
      def log_request(request, status, headers, duration)
        logger.info { request_line(request, duration, status) }

        logger.info { status_line(status) }

        if request.params.any?
          logger.info { params_line(request.params) }
        end

        if headers["Location"]
          logger.info { redirect_line(headers["Location"]) }
        end
      end

      # Format the request line
      def request_line(request, duration, status)
        method = request.request_method
        path = filter_path(request.path)
        duration_text = "(#{format_duration(duration)})"

        "#{method} #{path} #{duration_text}".colorize(status_to_color(status)).bold
      end

      # Format the status line
      def status_line(status)
        status_text = "#{status} #{Rack::Utils::HTTP_STATUS_CODES[status]}"
        "Status: #{status_text}".colorize(status_to_color(status)).bold
      end

      # Format the parameters line
      def params_line(params)
        filtered = filter_params(params)
        "Params: #{filtered.inspect}"
      end

      # Format the redirect line
      def redirect_line(location)
        "Redirect: #{location}".colorize(:yellow)
      end

      # Filter the request path
      def filter_path(path)
        path
      end

      # Filter request parameters
      def filter_params(params)
        ParameterFilter.new.filter(params)
      end

      # Determine color based on HTTP status
      def status_to_color(status)
        case status
        when 200..299 then :green
        when 300..399 then :yellow
        when 400..499 then :magenta
        when 500..599 then :red
        else :white
        end
      end
    end
  end
end
