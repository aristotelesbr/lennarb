# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

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
			def self.inherited(subclass)
				subclass.instance_variable_set(:@_route, Lennarb.new)
				subclass.instance_variable_set(:@_middlewares, [])
				subclass.instance_variable_set(:@_global_after_hooks, [])
				subclass.instance_variable_set(:@_global_before_hooks, [])
				subclass.instance_variable_set(:@_after_hooks, Lennarb::RouteNode.new)
				subclass.instance_variable_set(:@_before_hooks, Lennarb::RouteNode.new)
			end

			def self.get(...)     = @_route.get(...)
			def self.put(...)     = @_route.put(...)
			def self.post(...)    = @_route.post(...)
			def self.head(...)    = @_route.head(...)
			def self.match(...)   = @_route.match(...)
			def self.patch(...)   = @_route.patch(...)
			def self.delete(...)  = @_route.delete(...)
			def self.options(...) = @_route.options(...)

			# @returns [Array] middlewares
			def self.middlewares = @_middlewares

			# Use a middleware
			#
			# @parameter [Object] middleware
			# @parameter [Array] args
			# @parameter [Block] block
			#
			# @returns [Array] middlewares
			#
			def self.use(middleware, *args, &block)
				@_middlewares << [middleware, args, block]
			end

			# Add a before hook
			#
			# @parameter [String] path
			# @parameter [Block] block
			#
			def self.before(path = nil, &block)
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
			def self.after(path = nil, &block)
				if path
					parts = path.split('/').reject(&:empty?)
					@_after_hooks.add_route(parts, :after, block)
				else
					@_global_after_hooks << block
				end
			end

			# Call the application
			#
			# @parameter [Hash] env
			#
			# @returns [Array] response
			#
			def self.call(env)
				response =
					catch(:halt) do
						execute_hooks(@_before_hooks, env, :before)

						res = @_route.call(env)

						execute_hooks(@_after_hooks, env, :after)
						res
					end

				case response
				in [404 | 404, _, _] if html_request?(env) && File.exist?('public/404.html')
					env['PATH_INFO'] = '/404.html'
					Rack::Static.new(-> { response }, urls: ['/404.html'], root: 'public').call(env)
				in [404 | 404, _, _] then response
				else
					response.is_a?(Array) ? response : response.finish
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
			#  - Rack::Lint
			#  - Rack::MethodOverride
			#  - Rack::Head
			#  - Rack::ContentLength
			#  - Rack::Static
			#
			def self.run!
				stack = Rack::Builder.new

				use Rack::ShowExceptions
				use Rack::Lint
				use Rack::MethodOverride
				use Rack::Head
				use Rack::ContentLength
				use Rack::Static,
								root: 'public',
								urls: ['/404.html'],
								header_rules: [
									[200, %w[html], { 'content-type' => 'text/html; charset=utf-8' }]
								]

				middlewares.each do |(middleware, args, block)|
					stack.use(middleware, *args, &block)
				end

				stack.run @_route

				@_route.freeze!

				@_route = stack.to_app.freeze

				self
			end

			# Redirect to a path
			#
			# @parameter [String] path
			# @parameter [Integer] status default is 302
			# @parameter [Hash] env (optional)
			#
			def self.redirect(path, status = 302, _env = nil)
				response = Rack::Response.new([], status, 'location' => path)
				throw :halt, response.finish
			end

			# Execute the hooks
			#
			# @parameter [RouteNode] hook_route
			# @parameter [Hash] env
			# @parameter [Symbol] action
			#
			# @returns [void]
			#
			def self.execute_hooks(hook_route, env, action)
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
			def self.execute_global_hooks(env, action)
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
			def self.execute_route_hooks(hook_route, env, action)
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
			def self.parse_path(env) = env[Rack::PATH_INFO]&.split('/')&.reject(&:empty?)

			# Check if the request is a HTML request
			#
			# @parameter [Hash] env
			#
			# @returns [Boolean]
			#
			def self.html_request?(env) = env['HTTP_ACCEPT']&.include?('text/html')

			private_class_method :execute_hooks, :execute_global_hooks, :execute_route_hooks, :parse_path, :html_request?
		end
	end
end
