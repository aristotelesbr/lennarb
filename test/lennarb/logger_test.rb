require "test_helper"

class LoggerTest < Minitest::Test
  let(:io) { StringIO.new }

  def io_read(buffer = io)
    buffer.tap(&:rewind).read
  end

  test "logs message to buffer" do
    logger = Lennarb::Logger.new(Logger.new(io, level: Logger::DEBUG))
    logger.debug "debug message"
    assert_includes io_read, "debug message"
  end

  test "logs tag message to buffer" do
    logger = Lennarb::Logger.new(Logger.new(io, level: Logger::DEBUG), tag: :app)
    logger.debug "debug message"
    assert_includes io_read, "[app]"
    assert_includes io_read, "debug message"
  end

  test "adds nested tag" do
    logger = Lennarb::Logger.new(Logger.new(io, level: Logger::DEBUG), tag: :app)
    logger.tagged(:request).debug "nested tagged message"
    logger.tagged(:request) { it.debug "nested tagged message with block" }
    logger.debug "debug message"

    content = io_read

    assert_includes content, "[app]"
    assert_includes content, "[request]"
    assert_includes content, "nested tagged message"
    assert_includes content, "nested tagged message with block"
    assert_includes content, "debug message"
  end

  test "respects log level" do
    std_logger = Logger.new(io, level: Logger::WARN)
    logger = Lennarb::Logger.new(std_logger)

    logger.debug "debug message"
    logger.info "info message"
    logger.warn "warn message"

    content = io_read
    refute_includes content, "debug message"
    refute_includes content, "info message"
    assert_includes content, "warn message"
  end

  test "supports method chaining" do
    logger = Lennarb::Logger.new(Logger.new(io, level: Logger::DEBUG))
    result = logger.debug("first").info("second")
    assert_equal logger, result

    content = io_read
    assert_includes content, "first"
    assert_includes content, "second"
  end

  test "logs colored message to buffer" do
    std_logger = Logger.new(io, level: Logger::DEBUG)
    logger = Lennarb::Logger.new(
      std_logger,
      tag: :app,
      tag_color: :red,
      message_color: :blue,
      colorize: true
    )

    logger.debug "debug message"

    # Verificamos apenas a presença da mensagem e tags, já que a colorização
    # pode variar dependendo da implementação da gem colorize
    content = io_read
    assert_includes content, "[app]"
    assert_includes content, "debug message"

    # Verifica se há códigos ANSI de cores (presença de escape sequences)
    assert_includes content, "\e["
  end
end
