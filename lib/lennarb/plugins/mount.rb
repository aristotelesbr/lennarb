# frozen_string_literal: true

class Lennarb
  module Plugins
    module Mount
      def self.configure(app)
        app.instance_variable_set(:@_mounted_apps, {})
        app.extend(ClassMethods)
        app.include(InstanceMethods)
      end

      module ClassMethods
        def mount(app_class, at:)
          raise ArgumentError, 'Expected a Lennarb class' unless app_class.is_a?(Class) && app_class <= Lennarb
          raise ArgumentError, 'Mount path must start with /' unless at.start_with?('/')

          @_mounted_apps ||= {}
          normalized_path = normalize_mount_path(at)

          mounted_app = app_class.new
          mounted_app.freeze!

          @_mounted_apps[normalized_path] = mounted_app
        end

        private

        def normalize_mount_path(path)
          path.chomp('/')
        end
      end

      module InstanceMethods
        def call(env)
          path_info = env[Rack::PATH_INFO]

          self.class.instance_variable_get(:@_mounted_apps)&.each do |mount_path, app|
            next unless path_info.start_with?("#{mount_path}/") || path_info == mount_path

            env[Rack::PATH_INFO]   = path_info[mount_path.length..]
            env[Rack::PATH_INFO]   = '/' if env[Rack::PATH_INFO].empty?
            env[Rack::SCRIPT_NAME] = "#{env[Rack::SCRIPT_NAME]}#{mount_path}"

            return app.call(env)
          end

          super
        rescue StandardError => e
          handle_error(e)
        end

        private

        def handle_error(error)
          case error
          when ArgumentError
            [400, { 'content-type' => 'text/plain' }, ["Bad Request: #{error.message}"]]
          else
            [500, { 'content-type' => 'text/plain' }, ['Internal Server Error']]
          end
        end
      end
    end
    Lennarb::Plugin.register(:mount, Mount)
  end
end
