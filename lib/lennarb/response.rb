# frozen_string_literal: true

class Lennarb
  class Response
    # @!attribute [rw] status
    #  @return [Integer]
    #
    attr_accessor :status

    # @!attribute [r] body
    #  @return [Array]
    #
    attr_reader :body

    # @!attribute [r] headers
    #  @return [Hash]
    #
    attr_reader :headers

    # @!attribute [r] length
    #  @return [Integer]
    #
    attr_reader :length

    # Constants
    #
    LOCATION = 'location'
    private_constant :LOCATION

    CONTENT_TYPE = 'content-type'
    private_constant :CONTENT_TYPE

    CONTENT_LENGTH = 'content-length'
    private_constant :CONTENT_LENGTH

    ContentType = { HTML: 'text/html', TEXT: 'text/plain', JSON: 'application/json' }.freeze
    private_constant :ContentType

    # Initialize the response object
    #
    # @return [Response]
    #
    def initialize
      @status  = 404
      @headers = {}
      @body    = []
      @length  = 0
    end

    # Set the response header
    #
    # @parameter [String] key
    #
    # @return [String] value
    #
    def [](key)
      @headers[key]
    end

    # Get the response header
    #
    # @parameter [String] key
    # @parameter [String] value
    #
    # @return [String] value
    #
    def []=(key, value)
      @headers[key] = value
    end

    # Write to the response body
    #
    # @parameter [String] str
    #
    # @return [String] str
    #
    def write(str)
      str = str.to_s
      @length += str.bytesize
      @headers[CONTENT_LENGTH] ||= @length.to_s
      @body << str
    end

    # Set the response type to text
    #
    # @parameter [String] str
    #
    # @return [String] str
    #
    def text(str)
      @headers[CONTENT_TYPE] = ContentType[:TEXT]
      write(str)
    end

    # Set the response type to html
    #
    # @parameter [String] str
    #
    # @return [String] str
    #
    def html(str)
      @headers[CONTENT_TYPE] = ContentType[:HTML]
      write(str)
    end

    # Set the response type to json
    #
    # @parameter [String] str
    #
    # @return [String] str
    #
    def json(str)
      @headers[CONTENT_TYPE] = ContentType[:JSON]
      write(str)
    end

    # Redirect the response
    #
    # @parameter [String] path
    # @parameter [Integer] status, default: 302
    #
    def redirect(path, status = 302)
      @headers[LOCATION] = path
      @status = status
    end

    # Finish the response
    #
    # @return [Array] response
    #
    def finish
      [@status, @headers, @body]
    end
  end
end
