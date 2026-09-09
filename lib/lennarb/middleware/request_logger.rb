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

      # Get the logger for this request.
      #
      # Resolved from the app handling the request, which App#call publishes in
      # the Rack env, so an app's configured logger is actually used. Falls back
      # to the class-level default when there is no app in the env.
      #
      # @param [Hash, nil] env Rack environment
      # @return [Object] The logger
      def logger(env = nil)
        env&.[](RACK_LENNA_APP)&.config&.logger || Lennarb::App.app.config.logger
      end

      # Process the request and log information
      #
      # @param [Hash] env Rack environment
      # @return [Array] Rack response [status, headers, body]
      def call(env)
        request = Lennarb::Request.new(env)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        status, headers, body = @app.call(env)

        duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

        log_request(request, status, headers, duration, env)

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
      def log_request(request, status, headers, duration, env = nil)
        log = logger(env)

        log.info { request_line(request, duration, status) }

        log.info { status_line(status) }

        if request.params.any?
          log.info { params_line(request.params) }
        end

        # Rack 3 header names are lowercase; Response#redirect writes "location".
        location = headers["location"]
        log.info { redirect_line(location) } if location
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

      # Escape control characters in the request path.
      #
      # The path comes from the client, and an unescaped newline or ANSI escape
      # would let it forge log lines. Parameter values are already safe because
      # they go through #inspect.
      #
      # @param [String] path Request path
      # @return [String] Path safe to write to a log
      def filter_path(path)
        path.to_s.gsub(/[[:cntrl:]]/) { |char| format("\\x%02X", char.ord) }
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
