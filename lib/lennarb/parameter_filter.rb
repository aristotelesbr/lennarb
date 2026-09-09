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
  # - `auth`
  # - `credit`
  # - `card_number`
  # - `cvn`
  # - `iban`
  # - `api`
  # - `pin`
  # - `session_id`
  #
  # Matching is case-insensitive, so `Password` and `API_KEY` are filtered too.
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
      signature auth credit card_number cvn iban api pin session_id
    ].freeze

    # Initialize a new parameter filter
    #
    # Regexp filters are used as given. Anything else is matched as a literal
    # substring of the key, case-insensitively.
    #
    # @param [Array<String, Symbol, Regexp>] filters List of patterns to filter
    def initialize(filters = DEFAULT_FILTERS)
      union = Regexp.union(filters.map { |pattern| pattern.is_a?(Regexp) ? pattern : pattern.to_s })
      @filter = Regexp.new(union.source, Regexp::IGNORECASE)
    end

    # Filter parameters according to the configured filter
    #
    # @param [Hash, Array] params Parameters to be filtered
    # @param [String] mask Value that will replace filtered parameters
    # @return [Hash, Array] Filtered parameters
    def filter(params, mask: DEFAULT_MASK)
      filter_object(params, mask)
    end

    private

    # Recursively filter an object (hash or array).
    #
    # Builds new containers rather than writing into the ones it was given, so
    # the caller's parameters are never modified.
    #
    # @param [Object] object Object to be filtered
    # @param [String] mask Value that will replace filtered parameters
    # @return [Object] Filtered object
    def filter_object(object, mask)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), result|
          result[key] = key.to_s.match?(@filter) ? mask : filter_object(value, mask)
        end
      when Array
        object.map { filter_object(it, mask) }
      else
        object
      end
    end
  end
end
