# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

class Lennarb
	# This module must be included in the class that will use the router.
	#
	module ApplicationCore
		# Include the class methods
		#
		# @parameter [Array]   List of plugins
		# @parameter [Array]   List of middlewares
		# @parameter [Hash]    Hash of after hooks
		# @parameter [Hash]    Hash of before hooks
		# @parameter [Lennarb] Instance of the router
		# @parameter [Lennarb::Response] Instance of the response
		#
		def self.included(base)
			base.extend(ClassMethods)
			base.instance_variable_set(:@plugins, [])
			base.instance_variable_set(:@middlewares, [])
			base.instance_variable_set(:@after_hooks, {})
			base.instance_variable_set(:@before_hooks, {})
			base.instance_variable_set(:@router, Lennarb.new)
			base.instance_variable_set(:@res, Lennarb::Response.new)
		end

		module ClassMethods
			# Helper method to define a route
			#
			# @returns [Lennarb] instance of the router
			#
			def route = @router

			# Entry point of the application
			#
			def app
				route.freeze!

				middlewares = build_middleware_stack

				proc do |env|
					catch(:halt) { middlewares.call(env) }
				end
			end

			# Add a before hook, that will be executed before the route or especific path
			#
			# @parameter [String] path
			# @parameter [Proc]   block
			#
			# @returns [void]
			#
			def before(path = nil, &block)
				path ||= 'default'
				(@before_hooks[path] ||= []) << block
			end

			#
			# Add a after hook, that will be executed after the route or especific path
			#
			# @parameter [String] path
			# @parameter [Proc]   block
			#
			# @returns [void]
			#
			def after(path = nil, &block)
				path ||= 'default'
				(@after_hooks[path] ||= []) << block
			end

			# Add a new plugin
			#
			# @parameter [Proc] plugin
			# @parameter [Proc] block
			#
			def plug(plugin = nil, &block)
				plugin = block if block_given?
				@plugins << plugin if plugin
			end

			# Add a middleware
			#
			# @parameter [Proc]  middleware
			# @parameter [Array] args
			# @parameter [Proc]  block
			#
			def use(middleware, *args, &block) = @middlewares << [middleware, args, block]

			# Redirect helper
			#
			# @parameter [String] path
			# @parameter [Integer] status, default: 302
			#
			def redirect(path = nil, status = 302)
				@res.redirect(path, status)

				throw :halt, @res.finish
			end

			private

			# Build the middleware stack with the middlewares, plugins and hooks
			#
			# @returns [Proc]
			#
			def build_middleware_stack
				app =
					->(env) {
						@req = Lennarb::Request.new(env)
						path = @req.path_info

						execute_hooks_or_plugins(@before_hooks, path, @req)
						@plugins.each { |plugin| plugin.call(@req) }
						response = route.call(@req)
						execute_hooks_or_plugins(@after_hooks, path, @req)

						response
					}

				@middlewares.reverse.reduce(app) do |next_app, (middleware, args, block)|
					middleware.new(next_app, *args, &block)
				end
			end

			# Execute the hooks or plugins
			#
			# @parameter [Hash]   hooks_or_plugins
			# @parameter [String] path
			# @parameter [Hash]   env
			#
			def execute_hooks_or_plugins(hooks_or_plugins, path, env)
				if hooks_or_plugins.is_a?(Hash)
					(hooks_or_plugins[path] || []).each { |hook| hook.call(env) }
					(hooks_or_plugins['default'] || []).each { |hook| hook.call(env) }
				else
					hooks_or_plugins.each { |hook_or_plugin| hook_or_plugin.call(env) }
				end
			end
		end
	end
end
