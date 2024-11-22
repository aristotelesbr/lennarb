# frozen_string_literal: true

class Lennarb
  module Plugin
    class Error < StandardError; end

    @registry         = {}
    @defaults_loaded  = false

    class << self
      attr_reader :registry

      def register(name, mod)
        registry[name.to_sym] = mod
      end

      def load(name)
        registry[name.to_sym] || raise(Error, "Plugin #{name} not found")
      end

      def load_defaults!
        return if @defaults_loaded

        # 1. Register default plugins
        plugins_path = File.expand_path('plugins', __dir__)
        load_plugins_from_directory(plugins_path)

        # # 2. Register custom plugins
        ENV.fetch('LENNARB_PLUGINS_PATH', nil)&.split(File::PATH_SEPARATOR)&.each do |path|
          load_plugins_from_directory(path)
        end

        @defaults_loaded = true
      end

      def load_defaults?
        ENV.fetch('LENNARB_AUTO_LOAD_DEFAULTS', 'true') == 'true'
      end

      private

      def load_plugins_from_directory(path)
        raise Error, "Plugin directory '#{path}' does not exist" unless File.directory?(path)

        Dir["#{path}/**/*.rb"].each { require _1 }
      end
    end
  end
end
