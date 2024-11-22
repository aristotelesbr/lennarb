# frozen_string_literal: true

class Lennarb
  module Plugins
    module Hooks
      def self.configure(app)
        app.instance_variable_set(:@_before_hooks, {})
        app.instance_variable_set(:@_after_hooks, {})
        app.extend(ClassMethods)
        app.include(InstanceMethods)
      end

      module ClassMethods
        def before(paths = '*', &block)
          paths = Array(paths)
          @_before_hooks ||= {}

          paths.each do |path|
            @_before_hooks[path] ||= []
            @_before_hooks[path] << block
          end
        end

        def after(paths = '*', &block)
          paths = Array(paths)
          @_after_hooks ||= {}

          paths.each do |path|
            @_after_hooks[path] ||= []
            @_after_hooks[path] << block
          end
        end

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@_before_hooks, @_before_hooks&.dup || {})
          subclass.instance_variable_set(:@_after_hooks, @_after_hooks&.dup || {})
        end
      end

      module InstanceMethods
        def call(env)
          catch(:halt) do
            req = Lennarb::Request.new(env)
            res = Lennarb::Response.new

            path = env[Rack::PATH_INFO]

            execute_hooks(self.class.instance_variable_get(:@_before_hooks), '*', req, res)

            execute_matching_hooks(self.class.instance_variable_get(:@_before_hooks), path, req, res)

            status, headers, body = super
            res.status = status
            headers.each { |k, v| res[k] = v }
            body.each { |chunk| res.write(chunk) }

            execute_matching_hooks(self.class.instance_variable_get(:@_after_hooks), path, req, res)

            execute_hooks(self.class.instance_variable_get(:@_after_hooks), '*', req, res)

            res.finish
          end
        rescue StandardError => e
          handle_error(e)
        end

        private

        def execute_hooks(hooks, path, req, res)
          return unless hooks&.key?(path)

          hooks[path].each do |hook|
            instance_exec(req, res, &hook)
          end
        end

        def execute_matching_hooks(hooks, current_path, req, res)
          return unless hooks

          hooks.each do |pattern, pattern_hooks|
            next if pattern == '*'

            next unless matches_pattern?(pattern, current_path)

            pattern_hooks.each do |hook|
              instance_exec(req, res, &hook)
            end
          end
        end

        def matches_pattern?(pattern, path)
          return true if pattern == path

          pattern_parts = pattern.split('/')
          path_parts = path.split('/')

          return false if pattern_parts.length != path_parts.length

          pattern_parts.zip(path_parts).all? do |pattern_part, path_part|
            pattern_part.start_with?(':') || pattern_part == path_part
          end
        end

        def handle_error(error)
          case error
          when ArgumentError
            [400, { 'Content-Type' => 'text/plain' }, ["Bad Request: #{error.message}"]]
          else
            [500, { 'Content-Type' => 'text/plain' }, ['Internal Server Error']]
          end
        end
      end
    end
    Lennarb::Plugin.register(:hooks, Hooks)
  end
end
