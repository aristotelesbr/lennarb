# frozen_string_literal: true

# External dependencies
require 'puma'

# Internal dependencies
require 'lenna/middleware/default/error_handler'
require 'lenna/middleware/default/logging'
require 'lenna/router'

module Lenna
  # The base class is used to start the server.
  #
  class Application < Router
    # Initialize the base class
    #
    # @param block [Proc] The block to be executed
    #
    # @return [void]
    #
    # @example:
    #   Lenna::Base.new do |app|
    #     app.get('/hello') do |req, res|
    #       res.html('Hello World!')
    #     end
    #     app.get('/hello/:name') do |req, res|
    #       name = req.params[:name]
    #       res.html("Hello #{name}!")
    #     end
    #   end
    #
    # @api public
    #
    def initialize
      super

      yield self if block_given?
    end
    # The default port is 3000
    #
    DEFAULT_PORT = 3000
    private_constant :DEFAULT_PORT

    # The default host is localhost
    #
    DEFAULT_HOST = 'localhost'
    private_constant :DEFAULT_HOST

    # This method will start the puma server and listen on the specified port
    # and host. The default port is 3000 and the default host is localhost.
    # Use only in development.
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
    # # or specify the host and port
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
    #
    def listen(port = DEFAULT_PORT, host: DEFAULT_HOST, **)
      puts "⚡ Listening on #{host}:#{port}. \n Use Ctrl-C to stop the server."

      # Add the logging middleware to the stack
      use(Middleware::Default::Logging, Middleware::Default::ErrorHandler)

      server = ::Puma::Server.new(self, **)
      server.add_tcp_listener(host, port)
      server.run.join
    end
  end
end