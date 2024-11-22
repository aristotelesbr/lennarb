# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

class Lennarb
  class Request < Rack::Request
    # The environment variables of the request
    #
    # @returns [Hash]
    #
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
      @route_params = route_params
    end

    # Get the request body
    #
    # @returns [String]
    #
    def params = @params ||= super.merge(@route_params)&.transform_keys(&:to_sym)

    # Get the request path
    #
    # @returns [String]
    #
    def path = @path ||= super.split('?').first

    # Read the body of the request
    #
    # @returns [String]
    #
    def body = @body ||= super.read

    # Get the query parameters
    #
    # @returns [Hash]
    #
    def query_params
      @query_params ||= Rack::Utils.parse_nested_query(query_string).transform_keys(&:to_sym)
    end

    # Get the headers of the request
    #
    def headers
      @headers ||= env.select { |key, _| key.start_with?('HTTP_') }
    end

    def ip             = ip_address
    def secure?        = scheme == 'https'
    def user_agent     = headers['HTTP_USER_AGENT']
    def accept         = headers['HTTP_ACCEPT']
    def referer        = headers['HTTP_REFERER']
    def host           = headers['HTTP_HOST']
    def content_length = headers['HTTP_CONTENT_LENGTH']
    def content_type   = headers['HTTP_CONTENT_TYPE']
    def xhr?           = headers['HTTP_X_REQUESTED_WITH']&.casecmp('XMLHttpRequest')&.zero?

    def []=(key, value)
      env[key] = value
    end

    def [](key)
      env[key]
    end

    private

    def ip_address
      forwarded_for = headers['HTTP_X_FORWARDED_FOR']
      forwarded_for ? forwarded_for.split(',').first.strip : env['REMOTE_ADDR']
    end
  end
end
