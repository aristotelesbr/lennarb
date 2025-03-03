module Lennarb
  # The configuration for the application.
  # It uses {https://rubygems.org/gems/superconfig SuperConfig} to define the
  # configuration.
  class Config < SuperConfig::Base
    undef_method :credential

    def initialize(**)
      block = proc { true }
      super(**, &block)
    end

    # @private
    def to_s = "#<Lennarb::Config>"

    # @private
    def mandatory(*, **)
      super
    rescue SuperConfig::MissingEnvironmentVariable => error
      raise MissingEnvironmentVariable, error.message
    end

    # @private
    def property(*, **, &)
      super
    rescue SuperConfig::MissingCallable
      raise MissingCallable,
        "arg[1] must respond to #call or a block must be provided"
    end
  end
end
