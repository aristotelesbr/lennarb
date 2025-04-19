module Lennarb
  # Request object
  #
  class Request < Rack::Request
    # The environment variables of the request
    #
    # @return [Hash]
    attr_reader :env

    # Initialize the request object
    #
    # @param [Hash] env
    # @param [Hash] route_params
    #
    # @return [Request]
    #
    def initialize(env, route_params = {})
      super(env)
      @route_params = route_params || {}
    end

    # Get the request parameters merged with route parameters
    #
    # @return [Hash]
    #
    def params
      @params ||= super.merge(@route_params)&.transform_keys(&:to_sym)
    end

    # Get the request path without query string
    #
    # @return [String]
    #
    def path
      @path ||= super.split("?").first
    end

    # Read the body of the request
    #
    # @return [String]
    #
    def body
      @body ||= super.read
    end

    # Get the query parameters
    #
    # @return [Hash]
    #
    def query_params
      @query_params ||= Rack::Utils.parse_nested_query(query_string || "").transform_keys(&:to_sym)
    end

    # Set a value in the environment
    #
    # @param [String] key
    # @param [Object] value
    # @return [Object] the value
    #
    def []=(key, value)
      env[key] = value
    end

    # Get a value from the environment
    #
    # @param [String] key
    # @return [Object]
    #
    def [](key)
      env[key]
    end

    # Get the headers of the request
    #
    # @return [Hash]
    #
    def headers
      @headers ||= env.each_with_object({}) do |(key, value), result|
        if key.start_with?("HTTP_")
          header_name = key.sub("HTTP_", "").split("_").map(&:capitalize).join("-")
          result[header_name] = value
        end
      end
    end

    # Get the client IP address
    #
    # @return [String]
    #
    def ip
      ip_address
    end

    # Check if the request is secure (HTTPS)
    #
    # @return [Boolean]
    #
    def secure?
      scheme == "https"
    end

    # Shorthand methods for common headers

    # Get the user agent
    #
    # @return [String, nil]
    #
    def user_agent
      env["HTTP_USER_AGENT"]
    end

    # Get the accept header
    #
    # @return [String, nil]
    #
    def accept
      env["HTTP_ACCEPT"]
    end

    # Get the referer header
    #
    # @return [String, nil]
    #
    def referer
      env["HTTP_REFERER"]
    end

    # Get the host header
    #
    # @return [String, nil]
    #
    def host
      env["HTTP_HOST"]
    end

    # Get the content length header
    #
    # @return [String, nil]
    #
    def content_length
      env["HTTP_CONTENT_LENGTH"]
    end

    # Get the content type header
    #
    # @return [String, nil]
    #
    def content_type
      env["HTTP_CONTENT_TYPE"]
    end

    # Check if the request is an XHR request
    #
    # @return [Boolean]
    #
    def xhr?
      env["HTTP_X_REQUESTED_WITH"]&.casecmp("XMLHttpRequest")&.zero? || false
    end

    # Check if the request is a JSON request
    #
    # @return [Boolean]
    #
    def json?
      content_type&.include?("application/json")
    end

    # Parse JSON body if content type is application/json
    #
    # @return [Hash, nil]
    #
    def json_body
      return nil unless json?
      @json_body ||= begin
        JSON.parse(body, symbolize_names: true)
      rescue JSON::ParserError
        nil
      end
    end

    # Check if the request is an AJAX request (alias for xhr?)
    #
    # @return [Boolean]
    #
    def ajax?
      xhr?
    end

    # Get the requested format (.html, .json, etc)
    #
    # @return [Symbol, nil]
    #
    def format
      @format ||= begin
        path_info = env["PATH_INFO"]
        return nil unless path_info.include?(".")

        extension = File.extname(path_info).delete(".")
        extension.empty? ? nil : extension.to_sym
      end
    end

    # Check if the request is a GET request
    #
    # @return [Boolean]
    #
    def get?
      request_method == "GET"
    end

    # Check if the request is a POST request
    #
    # @return [Boolean]
    #
    def post?
      request_method == "POST"
    end

    # Check if the request is a PUT request
    #
    # @return [Boolean]
    #
    def put?
      request_method == "PUT"
    end

    # Check if the request is a DELETE request
    #
    # @return [Boolean]
    #
    def delete?
      request_method == "DELETE"
    end

    # Check if the request is a HEAD request
    #
    # @return [Boolean]
    #
    def head?
      request_method == "HEAD"
    end

    # Check if the request is a PATCH request
    #
    # @return [Boolean]
    #
    def patch?
      request_method == "PATCH"
    end

    private

    # Get the client IP address
    #
    # @return [String]
    #
    def ip_address
      forwarded_for = env["HTTP_X_FORWARDED_FOR"]
      return forwarded_for.split(",").map(&:strip).first if forwarded_for

      env["REMOTE_ADDR"]
    end
  end
end
