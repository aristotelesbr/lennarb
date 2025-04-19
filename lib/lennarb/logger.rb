module Lennarb
  class Logger
    # @api private
    LEVELS = {
      debug: ::Logger::DEBUG,
      info: ::Logger::INFO,
      warn: ::Logger::WARN,
      error: ::Logger::ERROR,
      fatal: ::Logger::FATAL
    }.freeze

    # @api private
    DEFAULT_FORMATTER = proc do |options|
      line = [options[:tag], options[:message]].compact.join(" ")
      "#{line}\n"
    end

    # Initialize a new logger
    #
    # @param [::Logger] logger Logger instance to use
    # @param [Proc] formatter Custom formatter for messages
    # @param [Array, String, Symbol, nil] tag Tag to identify log messages
    # @param [Symbol, nil] tag_color Color for the tag
    # @param [Symbol, nil] message_color Color for the message
    # @param [Boolean] colorize Force colorization even when not TTY
    def initialize(
      logger = ::Logger.new($stdout, level: ::Logger::INFO),
      formatter: DEFAULT_FORMATTER,
      tag: nil,
      tag_color: nil,
      message_color: nil,
      colorize: false
    )
      @logger = logger.dup
      @logger.formatter = proc { |*args| format_log(*args) }
      @tag = Array(tag)
      @formatter = formatter
      @tag_color = tag_color
      @message_color = message_color
      @colorize = colorize || $stdout.tty?
    end

    # Create a new logger with additional tags
    #
    # @param [Array<Symbol, String>] tags Additional tags
    # @yield [logger] Block to execute with the new logger
    # @return [Logger] New instance with added tags
    #
    # @example With block
    #   logger.tagged(:api) { |l| l.info("message") }
    #
    # @example Without block
    #   api_logger = logger.tagged(:api)
    #   api_logger.info("message")
    def tagged(*tags)
      new_logger = Logger.new(
        @logger,
        formatter: @formatter,
        tag: @tag.dup.concat(tags),
        tag_color: @tag_color,
        message_color: @message_color,
        colorize: @colorize
      )

      yield new_logger if block_given?

      new_logger
    end

    # Define methods for each log level
    # debug, info, warn, error, fatal
    LEVELS.each_key do |level|
      define_method(level) do |message = nil, &block|
        return self if @logger.level > LEVELS[level]

        message = block.call if block && !message
        @logger.add(LEVELS[level], message)

        self
      end
    end

    private

    # Format the log message
    def format_log(_severity, _time, _progname, message)
      tag = @tag.map { |t| "[#{t}]" }.join(" ")
      tag = colorize_text(tag, @tag_color)
      message = colorize_text(message, @message_color)

      @formatter.call(message: message, tag: tag.empty? ? nil : tag)
    end

    def colorize_text(text, color)
      return text.to_s unless @colorize
      return text.to_s if color.nil?
      text.to_s.colorize(color)
    end
  end
end
