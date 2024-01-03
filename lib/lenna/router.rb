# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'erb'
require 'json'

# External dependencies
require 'rack'

# Internal dependencies
require 'lenna/middleware/app'
require 'lenna/middleware/default/error_handler'
require 'lenna/middleware/default/logging'
require 'lenna/router/builder'
require 'lenna/router/cache'
require 'lenna/router/namespace_stack'
require 'lenna/router/request'
require 'lenna/router/response'
require 'lenna/router/route_matcher'

module Lenna
	# The Node struct is used to represent a node in the tree of routes.
	#
	#
	class TrieNode
		# @!attribute [rw] children
		#   @return [Hash] the children of the node
		#
		attr_accessor :children

		# @!attribute [rw] endpoint
		#   @return [Boolean] whether the node is an endpoint
		#
		attr_accessor :endpoint

		# @!attribute [rw] blocks
		#   @return [Hash] the blocks of the node
		#
		attr_accessor :blocks

		# This method is used to initialize the node.
		#
		# @return [void]
		#
		def initialize
			@blocks   = {}
			@children = {}
			@endpoint = false
		end
	end

	# The router class is responsible for adding routes and calling the
	# middleware chain for each request.
	#
	# @private
	#
	class Router
		# @!attribute [r] root_node
		#   @return [TrieNode] the root node of the tree of routes
		attr_reader :root_node

		# @!attribute [r] namespace_prefix
		#   @return [String] the namespace prefix
		attr_reader :namespace_prefix

		# @!attribute [r] route_cache
		#   @return [Hash] the route cache
		attr_reader :route_cache

		# This method is used to initialize the router.
		#
		# @return [void]
		#
		def initialize
			@root_node = TrieNode.new
			@namespace_prefix = ''
			@route_cache = {}
		end

		# This method is used to add a route to the router.
		#
		# @parameter method [String] the method of the route
		# @parameter path   [String] the path of the route
		# @parameter block  [Proc]   the block to be executed
		#
		# @return           [void]
		#
		# @private `Since v0.1`
		#
		# See {Route::Builder#add_route}
		#
		def add_route(method, path, &block)
			full_path = "#{@namespace_prefix}#{path}"

			segments = "#{method}#{full_path}".split('/').reject(&:empty?)

			current_node = @root_node

			segments.each do |segment|
				current_node.children[segment] ||= TrieNode.new
				current_node = current_node.children[segment]
			end

			current_node.endpoint = true
			current_node.blocks[method.upcase] = block # Armazena o bloco com a chave do método
		end

		# This method will create the nodes that are missing.
		#
		# @parameter method [String] the method of the route. Ex. 'GET'
		# @parameter path   [String] the path of the route.   Ex. '/'
		#
		# @return           [Array]  the block and the params
		#
		# @private `Since v0.1`
		# See {Route::Builder#find_route}
		#
		def find_route(method, path)
			cache_key = "#{method}#{path}"

			return @route_cache[cache_key] if @route_cache.key?(cache_key)

			segments = [method.upcase] + path.split('/').reject(&:empty?)
			current_node = @root_node
			params = {}

			segments.each do |segment|
				if current_node.children[segment]
					current_node = current_node.children[segment]
				elsif dynamic_segment = current_node.children.find { |k, _v| k.start_with?(':') }
					key, node = dynamic_segment
					params[key[1..].to_sym] = segment
					current_node = node
				else
					return nil # Rota não encontrada
				end
			end

			return unless current_node.endpoint

			block = current_node.blocks[method.upcase]
			return unless block

			@route_cache[cache_key] = [block, params] if block

			[block, params]
		end

		# This method is used to add a namespace to the routes.
		#
		# @parameter prefix [String] the prefix to be used
		# @parameter block  [Proc]   the block to be executed
		#
		# @return           [void]
		#
		# @private `Since v0.1`
		#
		def add_namespace(prefix)
			raise ::ArgumentError, 'block not given' unless block_given?

			previous_prefix = @namespace_prefix
			@namespace_prefix = "#{previous_prefix}/#{prefix}".squeeze('/')
			yield
			@namespace_prefix = previous_prefix
		end
	end
end
