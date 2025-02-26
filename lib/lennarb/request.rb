module Lennarb
  class Request < Rack::Request
    # The environment variables of the request
    #
    # @returns [Hash]
    attr_reader :env

    # Initialize the request object
    #
    # @parameter [Hash] env
    # @parameter [Hash] route_params
    #
    # @returns [Request]
    #
    def initialize(env, route_params = {})
      super(env)
      @route_params = route_params || {}
    end

    # Get the request parameters merged with route parameters
    #
    # @returns [Hash]
    #
    def params
      @params ||= super.merge(@route_params)&.transform_keys(&:to_sym)
    end

    # Get the request path without query string
    #
    # @returns [String]
    #
    def path
      @path ||= super.split("?").first
    end

    # Read the body of the request
    #
    # @returns [String]
    #
    def body
      @body ||= super.read
    end

    # Get the query parameters
    #
    # @returns [Hash]
    #
    def query_params
      @query_params ||= Rack::Utils.parse_nested_query(query_string || "").transform_keys(&:to_sym)
    end

    # Set a value in the environment
    #
    # @parameter [String] key
    # @parameter [Object] value
    # @returns [Object] the value
    #
    def []=(key, value)
      env[key] = value
    end

    # Get a value from the environment
    #
    # @parameter [String] key
    # @returns [Object]
    #
    def [](key)
      env[key]
    end

    # Get the headers of the request
    #
    # @returns [Hash]
    #
    def headers
      @headers ||= env.select { |key, _| key.start_with?("HTTP_") }
    end

    # Get the client IP address
    #
    # @returns [String]
    #
    def ip
      ip_address
    end

    # Check if the request is secure (HTTPS)
    #
    # @returns [Boolean]
    #
    def secure?
      scheme == "https"
    end

    # Shorthand methods for common headers

    # Get the user agent
    #
    # @returns [String, nil]
    #
    def user_agent
      env["HTTP_USER_AGENT"]
    end

    # Get the accept header
    #
    # @returns [String, nil]
    #
    def accept
      env["HTTP_ACCEPT"]
    end

    # Get the referer header
    #
    # @returns [String, nil]
    #
    def referer
      env["HTTP_REFERER"]
    end

    # Get the host header
    #
    # @returns [String, nil]
    #
    def host
      env["HTTP_HOST"]
    end

    # Get the content length header
    #
    # @returns [String, nil]
    #
    def content_length
      env["HTTP_CONTENT_LENGTH"]
    end

    # Get the content type header
    #
    # @returns [String, nil]
    #
    def content_type
      env["HTTP_CONTENT_TYPE"]
    end

    # Check if the request is an XHR request
    #
    # @returns [Boolean]
    #
    def xhr?
      env["HTTP_X_REQUESTED_WITH"]&.casecmp("XMLHttpRequest")&.zero? || false
    end

    # Check if the request is a JSON request
    #
    # @returns [Boolean]
    #
    def json?
      content_type&.include?("application/json")
    end

    # Parse JSON body if content type is application/json
    #
    # @returns [Hash, nil]
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
    # @returns [Boolean]
    #
    def ajax?
      xhr?
    end

    # Get the requested format (.html, .json, etc)
    #
    # @returns [Symbol, nil]
    #
    def format
      path_info = env["PATH_INFO"]
      return nil unless path_info.include?(".")

      extension = File.extname(path_info).delete(".")
      extension.empty? ? nil : extension.to_sym
    end

    # Check if the request is a GET request
    #
    # @returns [Boolean]
    #
    def get?
      request_method == "GET"
    end

    # Check if the request is a POST request
    #
    # @returns [Boolean]
    #
    def post?
      request_method == "POST"
    end

    # Check if the request is a PUT request
    #
    # @returns [Boolean]
    #
    def put?
      request_method == "PUT"
    end

    # Check if the request is a DELETE request
    #
    # @returns [Boolean]
    #
    def delete?
      request_method == "DELETE"
    end

    # Check if the request is a HEAD request
    #
    # @returns [Boolean]
    #
    def head?
      request_method == "HEAD"
    end

    # Check if the request is a PATCH request
    #
    # @returns [Boolean]
    #
    def patch?
      request_method == "PATCH"
    end

    private

    # Get the client IP address
    #
    # @returns [String]
    #
    def ip_address
      forwarded_for = env["HTTP_X_FORWARDED_FOR"]
      forwarded_for ? forwarded_for.split(",").first.strip : env["REMOTE_ADDR"]
    end
  end
end
