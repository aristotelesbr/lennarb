module Lennarb
  # Filters sensitive parameters from logs and exceptions.
  # Useful for preventing the leakage of confidential information.
  #
  # By default, the following parameter keys are filtered:
  #
  # - `passw`
  # - `email`
  # - `secret`
  # - `token`
  # - `_key`
  # - `crypt`
  # - `salt`
  # - `certificate`
  # - `otp`
  # - `ssn`
  # - `cvv`
  # - `cvc`
  # - `signature`
  #
  # @example
  #   filter = Lennarb::ParameterFilter.new
  #   filter.filter({ password: "secret", user: { email: "test@example.com" } })
  #   # => { password: "[filtered]", user: { email: "[filtered]" } }
  #
  class ParameterFilter
    # @api private
    DEFAULT_MASK = "[FILTERED]"

    # @api private
    DEFAULT_FILTERS = %w[
      passw email secret token _key crypt salt certificate otp ssn cvv cvc
      signature
    ].freeze

    # Initialize a new parameter filter
    #
    # @param [Array<String, Regexp>] filters List of patterns to filter
    def initialize(filters = DEFAULT_FILTERS)
      @filter = Regexp.union(filters.map(&:to_s))
    end

    # Filter parameters according to the configured filter
    #
    # @param [Hash, Array] params Parameters to be filtered
    # @param [String] mask Value that will replace filtered parameters
    # @return [Hash, Array] Filtered parameters
    def filter(params, mask: DEFAULT_MASK)
      filter_object(params.dup, mask)
    end

    private

    # Recursively filter an object (hash or array)
    #
    # @param [Object] object Object to be filtered
    # @param [String] mask Value that will replace filtered parameters
    # @return [Object] Filtered object
    def filter_object(object, mask)
      case object
      when Hash
        object.each do |key, value|
          object[key] = if key.to_s.match?(@filter)
            mask
          else
            filter_object(value, mask)
          end
        end
      when Array
        object = object.map { filter_object(it, mask) }
      end

      object
    end
  end
end
