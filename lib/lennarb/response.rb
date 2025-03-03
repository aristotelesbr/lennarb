module Lennarb
  # Response object
  #
  class Response
    # @!attribute [rw] status
    # @return [Integer]
    #
    attr_accessor :status

    # @!attribute [r] body
    # @retrn [Array]
    #
    attr_reader :body

    # @!attribute [r] headers
    # @retrn [Hash]
    #
    attr_reader :headers

    # @!attribute [r] length
    # @retrn [Integer]
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
    # @retrn [Response]
    #
    def initialize
      @status = 200
      @headers = {}
      @body = []
      @length = 0
    end

    # Set the response header
    #
    # @param [String] key
    #
    # @retrn [String] value
    #
    def [](key)
      @headers[key]
    end

    # Get the response header
    #
    # @param [String] key
    # @param [String] value
    #
    # @retrn [String] value
    #
    def []=(key, value)
      @headers[key] = value
    end

    # Write to the response body
    #
    # @param [String] str
    #
    # @retrn [String] str
    #
    def write(str)
      str = str.to_s
      @length += str.bytesize
      @headers[CONTENT_LENGTH] = @length.to_s
      @body << str
    end

    # Set the response type to text
    #
    # @param [String] str
    #
    # @retrn [String] str
    #
    def text(str)
      @headers[CONTENT_TYPE] = Lennarb::CONTENT_TYPE[:TEXT]
      write(str)
    end

    # Set the response type to html
    #
    # @param [String] str
    #
    # @retrn [String] str
    #
    def html(str)
      @headers[CONTENT_TYPE] = Lennarb::CONTENT_TYPE[:HTML]
      write(str)
    end

    # Set the response type to json
    #
    # @param [String] str
    #
    # @retrn [String] str
    #
    def json(str)
      json_str = JSON.generate(str)
      @headers[CONTENT_TYPE] = Lennarb::CONTENT_TYPE[:JSON]
      write(json_str)
    rescue JSON::GeneratorError => e
      @status = 500
      @headers[CONTENT_TYPE] = Lennarb::CONTENT_TYPE[:TEXT]
      write("JSON generation error: #{e.message}")
    end

    # Redirect the response
    #
    # @param [String] path
    # @param [Integer] status, default: 302
    #
    def redirect(path, status = 302)
      @headers[LOCATION] = path
      @status = status

      throw :halt, finish
    end

    # Finish the response
    #
    # @retrn [Array] response
    #
    def finish
      [@status, @headers, @body]
    end
  end
end
