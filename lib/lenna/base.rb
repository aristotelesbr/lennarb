# frozen_string_literal: true

# External dependencies
require 'puma'

# Internal dependencies
require_relative 'middleware/default/error_handler'
require_relative 'middleware/default/logging'
require_relative 'router'

module Lenna
  # The base class is used to start the server.
  class Base < Router
    DEFAULT_PORT = 3000
    private_constant :DEFAULT_PORT
    DEFAULT_HOST = 'localhost'
    private_constant :DEFAULT_HOST

    # This method will start the server.
    #
    # @param port [Integer] The port to listen on (default: 3000)
    # @param host [String]  The host to listen on (default: '
    # @return [void]
    #
    # @example
    #   app = Lenna::Base.new
    #   app.listen(8080)
    # # => ⚡ Listening on localhost:8080
    #
    # or specify the host and port
    #
    #   app = Lenna::Base.new
    #   app.listen(8000, host: '0.0.0.0')
    # # => ⚡ Listening on 0.0.0.0:8000
    #
    # @api public
    #
    # @todo: Add Lenna::Server to handle the server logic
    #
    # @since 0.1.0
    def listen(port = DEFAULT_PORT, host: DEFAULT_HOST, **)
      puts "⚡ Listening on #{host}:#{port}"

      # Add the logging middleware to the stack
      use(Middleware::Default::Logging, Middleware::Default::ErrorHandler)

      server = ::Puma::Server.new(self, **)
      server.add_tcp_listener(host, port)
      server.run.join
    end
  end
end
