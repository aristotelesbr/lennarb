# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

require 'colorize'

class Lennarb
	module Application
		class Base
			# @attribute [r] _route
			# @returns [RouteNode]
			#
			# @attribute [r] _middlewares
			# @returns [Array]
			#
			# @attribute [r] _global_after_hooks
			# @returns [Array]
			#
			# @attribute [r] _global_before_hooks
			# @returns [Array]
			#
			# @attribute [r] _after_hooks
			# @returns [RouteNode]
			#
			# @attribute [r] _before_hooks
			# @returns [RouteNode]
			#
			attr_accessor :_route, :_global_after_hooks, :_global_before_hooks, :_after_hooks, :_before_hooks

			# Initialize the Application
			#
			# @returns [Base]
			#

			class << self
				def inherited(subclass)
					subclass.instance_variable_set(:@_route, Lennarb.new)
					subclass.instance_variable_set(:@_middlewares, [])
					subclass.instance_variable_set(:@_global_after_hooks, [])
					subclass.instance_variable_set(:@_global_before_hooks, [])
					subclass.instance_variable_set(:@_after_hooks, Lennarb::RouteNode.new)
					subclass.instance_variable_set(:@_before_hooks, Lennarb::RouteNode.new)
				end

				def get(...)     = @_route.get(...)
				def put(...)     = @_route.put(...)
				def post(...)    = @_route.post(...)
				def head(...)    = @_route.head(...)
				def match(...)   = @_route.match(...)
				def patch(...)   = @_route.patch(...)
				def delete(...)  = @_route.delete(...)
				def options(...) = @_route.options(...)

				# @returns [Array] middlewares
				def middlewares = @_middlewares

				# Use a middleware
				#
				# @parameter [Object] middleware
				# @parameter [Array] args
				# @parameter [Block] block
				#
				# @returns [Array] middlewares
				#
				def use(middleware, *args, &block)
					@_middlewares << [middleware, args, block]
				end

				# Add a before hook
				#
				# @parameter [String] path
				# @parameter [Block] block
				#
				def before(path = nil, &block)
					if path
						parts = path.split('/').reject(&:empty?)
						@_before_hooks.add_route(parts, :before, block)
					else
						@_global_before_hooks << block
					end
				end

				# Add a after hook
				#
				# @parameter [String] path
				# @parameter [Block] block
				#
				def after(path = nil, &block)
					if path
						parts = path.split('/').reject(&:empty?)
						@_after_hooks.add_route(parts, :after, block)
					else
						@_global_after_hooks << block
					end
				end

				# Run the Application
				#
				# @returns [Base] self
				#
				# When you use this method, the application will be frozen. And you can't add more routes after that.
				# This method is used to run the application in a Rack server so, you can use the `rackup` command
				#     to run the application.
				# Ex. rackup -p 3000
				# This command will use the following middleware:
				#  - Rack::ShowExceptions
				#  - Rack::MethodOverride
				#  - Rack::Head
				#  - Rack::ContentLength
				#
				def run!
					stack = Rack::Builder.new

					use Rack::ShowExceptions if test? || development?
					use Rack::MethodOverride
					use Rack::Head
					use Rack::ContentLength

					middlewares.each do |(middleware, args, block)|
						stack.use(middleware, *args, &block)
					end

					stack.run ->(env) do
						catch(:halt) do
							execute_hooks(@_before_hooks, env, :before)
							res = @_route.call(env)
							execute_hooks(@_after_hooks, env, :after)
							res
						rescue StandardError => e
							render_error if production?

							puts e.message.red
							puts e.backtrace
							raise e
						end
					end

					@_route.freeze!

					stack.to_app
				end

				def test?        = ENV['RACK_ENV'] == 'test'        || ENV['LENNARB_ENV'] == 'test'
				def production?  = ENV['RACK_ENV'] == 'production'  || ENV['LENNARB_ENV'] == 'production'
				def development? = ENV['RACK_ENV'] == 'development' || ENV['LENNARB_ENV'] == 'development'

				# Render a not found
				#
				# @returns [void]
				#
				def render_not_found(content = nil)
					default = File.exist?('public/404.html')
					body = content || default || 'Not Found'
					throw :halt, [404, { 'content-type' => 'text/html' }, [body]]
				end

				# Render an error
				#
				# @returns [void]
				#
				def render_error(content = nil)
					default = File.exist?('public/500.html')
					body = content || default || 'Internal Server Error'
					throw :halt, [500, { 'content-type' => 'text/html' }, [body]]
				end

				# Redirect to a path
				#
				# @parameter [String] path
				# @parameter [Integer] status default is 302
				#
				def redirect(path, status = 302) = throw :halt, [status, { 'location' => path }, []]

				# Include a plugin in the application
				#
				# @parameter [String] plugin_name
				# @parameter [Array] args
				# @parameter [Block] block
				#
				# @returns [void]
				#
				def plugin(plugin_name, *, &)
					@_route.plugin(plugin_name, *, &)
					plugin_module = @_route.class::Plugin.load(plugin_name)

					include plugin_module::InstanceMethods if plugin_module.const_defined?(:InstanceMethods)
					extend plugin_module::ClassMethods     if plugin_module.const_defined?(:ClassMethods)
				end

				private

				# Execute the hooks
				#
				# @parameter [RouteNode] hook_route
				# @parameter [Hash] env
				# @parameter [Symbol] action
				#
				# @returns [void]
				#
				def execute_hooks(hook_route, env, action)
					execute_global_hooks(env, action)

					execute_route_hooks(hook_route, env, action)
				end

				# Execute the global hooks
				#
				# @parameter [Hash] env
				# @parameter [Symbol] action
				#
				# @returns [void]
				#
				def execute_global_hooks(env, action)
					global_hooks = action == :before ? @_global_before_hooks : @_global_after_hooks
					global_hooks.each { |hook| hook.call(env) }
				end

				# Execute the route hooks
				#
				# @parameter [RouteNode] hook_route
				# @parameter [Hash] env
				# @parameter [Symbol] action
				#
				# @returns [void]
				#
				def execute_route_hooks(hook_route, env, action)
					parts = parse_path(env)
					return unless parts

					block, = hook_route.match_route(parts, action)
					block&.call(env)
				end

				# Parse the path
				#
				# @parameter [Hash] env
				#
				# @returns [Array] parts
				#
				def parse_path(env) = env[Rack::PATH_INFO]&.split('/')&.reject(&:empty?)

				# Check if the request is a HTML request
				#
				# @parameter [Hash] env
				#
				# @returns [Boolean]
				#
				def html_request?(env) = env['HTTP_ACCEPT']&.include?('text/html')
			end
		end
	end
end
