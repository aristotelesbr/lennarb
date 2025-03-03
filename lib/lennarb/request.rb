module Lennarb
  # Request object
  #
  class Request < Rack::Request
    # The environment variables of the request
    #
    # @retrn [Hash]
    attr_reader :env

    # Initialize the request object
    #
    # @param [Hash] env
    # @param [Hash] route_params
    #
    # @retrn [Request]
    #
    def initialize(env, route_params = {})
      super(env)
      @route_params = route_params || {}
    end

    # Get the request parameters merged with route parameters
    #
    # @retrn [Hash]
    #
    def params
      @params ||= super.merge(@route_params)&.transform_keys(&:to_sym)
    end

    # Get the request path without query string
    #
    # @retrn [String]
    #
    def path
      @path ||= super.split("?").first
    end

    # Read the body of the request
    #
    # @retrn [String]
    #
    def body
      @body ||= super.read
    end

    # Get the query parameters
    #
    # @retrn [Hash]
    #
    def query_params
      @query_params ||= Rack::Utils.parse_nested_query(query_string || "").transform_keys(&:to_sym)
    end

    # Set a value in the environment
    #
    # @param [String] key
    # @param [Object] value
    # @retrn [Object] the value
    #
    def []=(key, value)
      env[key] = value
    end

    # Get a value from the environment
    #
    # @param [String] key
    # @retrn [Object]
    #
    def [](key)
      env[key]
    end

    # Get the headers of the request
    #
    # @retrn [Hash]
    #
    def headers
      @headers ||= env.select { |key, _| key.start_with?("HTTP_") }
    end

    # Get the client IP address
    #
    # @retrn [String]
    #
    def ip
      ip_address
    end

    # Check if the request is secure (HTTPS)
    #
    # @retrn [Boolean]
    #
    def secure?
      scheme == "https"
    end

    # Shorthand methods for common headers

    # Get the user agent
    #
    # @retrn [String, nil]
    #
    def user_agent
      env["HTTP_USER_AGENT"]
    end

    # Get the accept header
    #
    # @retrn [String, nil]
    #
    def accept
      env["HTTP_ACCEPT"]
    end

    # Get the referer header
    #
    # @retrn [String, nil]
    #
    def referer
      env["HTTP_REFERER"]
    end

    # Get the host header
    #
    # @retrn [String, nil]
    #
    def host
      env["HTTP_HOST"]
    end

    # Get the content length header
    #
    # @retrn [String, nil]
    #
    def content_length
      env["HTTP_CONTENT_LENGTH"]
    end

    # Get the content type header
    #
    # @retrn [String, nil]
    #
    def content_type
      env["HTTP_CONTENT_TYPE"]
    end

    # Check if the request is an XHR request
    #
    # @retrn [Boolean]
    #
    def xhr?
      env["HTTP_X_REQUESTED_WITH"]&.casecmp("XMLHttpRequest")&.zero? || false
    end

    # Check if the request is a JSON request
    #
    # @retrn [Boolean]
    #
    def json?
      content_type&.include?("application/json")
    end

    # Parse JSON body if content type is application/json
    #
    # @retrn [Hash, nil]
    #
    def json_body
      return nil unless json?
      @json_body ||= begin
        require "json"
        JSON.parse(body, symbolize_names: true)
      rescue JSON::ParserError
        nil
      end
    end

    # Check if the request is an AJAX request (alias for xhr?)
    #
    # @retrn [Boolean]
    #
    def ajax?
      xhr?
    end

    # Get the requested format (.html, .json, etc)
    #
    # @retrn [Symbol, nil]
    #
    def format
      path_info = env["PATH_INFO"]
      return nil unless path_info.include?(".")

      extension = File.extname(path_info).delete(".")
      extension.empty? ? nil : extension.to_sym
    end

    # Check if the request is a GET request
    #
    # @retrn [Boolean]
    #
    def get?
      request_method == "GET"
    end

    # Check if the request is a POST request
    #
    # @retrn [Boolean]
    #
    def post?
      request_method == "POST"
    end

    # Check if the request is a PUT request
    #
    # @retrn [Boolean]
    #
    def put?
      request_method == "PUT"
    end

    # Check if the request is a DELETE request
    #
    # @retrn [Boolean]
    #
    def delete?
      request_method == "DELETE"
    end

    # Check if the request is a HEAD request
    #
    # @retrn [Boolean]
    #
    def head?
      request_method == "HEAD"
    end

    # Check if the request is a PATCH request
    #
    # @retrn [Boolean]
    #
    def patch?
      request_method == "PATCH"
    end

    private

    # Get the client IP address
    #
    # @retrn [String]
    #
    def ip_address
      forwarded_for = env["HTTP_X_FORWARDED_FOR"]
      forwarded_for ? forwarded_for.split(",").first.strip : env["REMOTE_ADDR"]
    end
  end
end
