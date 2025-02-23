module Lennarb
  class Response
    # @!attribute [rw] status
    #  @returns [Integer]
    #
    attr_accessor :status

    # @!attribute [r] body
    #  @returns [Array]
    #
    attr_reader :body

    # @!attribute [r] headers
    #  @returns [Hash]
    #
    attr_reader :headers

    # @!attribute [r] length
    #  @returns [Integer]
    #
    attr_reader :length

    # Constants
    #
    LOCATION = "location"
    private_constant :LOCATION

    CONTENT_TYPE = "content-type"
    private_constant :CONTENT_TYPE

    CONTENT_LENGTH = "content-length"
    private_constant :CONTENT_LENGTH

    # Initialize the response object
    #
    # @returns [Response]
    #
    def initialize
      @status = 404
      @headers = {}
      @body = []
      @length = 0
    end

    # Set the response header
    #
    # @parameter [String] key
    #
    # @returns [String] value
    #
    def [](key)
      @headers[key]
    end

    # Get the response header
    #
    # @parameter [String] key
    # @parameter [String] value
    #
    # @returns [String] value
    #
    def []=(key, value)
      @headers[key] = value
    end

    # Write to the response body
    #
    # @parameter [String] str
    #
    # @returns [String] str
    #
    def write(str)
      str = str.to_s
      @length += str.bytesize
      @headers[CONTENT_LENGTH] = @length.to_s
      @body << str
    end

    # Set the response type to text
    #
    # @parameter [String] str
    #
    # @returns [String] str
    #
    def text(str)
      @headers[CONTENT_TYPE] = Lennarb::CONTENT_TYPE[:TEXT]
      write(str)
    end

    # Set the response type to html
    #
    # @parameter [String] str
    #
    # @returns [String] str
    #
    def html(str)
      @headers[CONTENT_TYPE] = Lennarb::CONTENT_TYPE[:HTML]
      write(str)
    end

    # Set the response type to json
    #
    # @parameter [String] str
    #
    # @returns [String] str
    #
    def json(str)
      @headers[CONTENT_TYPE] = Lennarb::CONTENT_TYPE[:JSON]
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

      throw :halt, finish
    end

    # Finish the response
    #
    # @returns [Array] response
    #
    def finish
      [@status, @headers, @body]
    end
  end
end
