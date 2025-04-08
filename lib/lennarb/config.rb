module Lennarb
  # The configuration for the application.
  # It uses {https://rubygems.org/gems/superconfig SuperConfig} to define the
  # configuration.
  class Config < SuperConfig::Base
    undef_method :credential

    attr_reader :app
    attr_accessor :stderr_output

    def initialize(app = nil, silent: !ENV["LENNARB_SILENT_LOGS"].nil?, **options)
      self.stderr_output = if silent
        nil
      else
        $stderr
      end

      @app = app
      block = proc { true }
      super(**options, &block)
      apply_defaults_settings
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

    private def apply_defaults_settings
      set :logger,
        Lennarb::Logger.new(
          ::Logger.new(stderr_output),
          colorize: true,
          tag: Lennarb::App.name
        )
      set :enable_reloading, false
    end
  end
end
