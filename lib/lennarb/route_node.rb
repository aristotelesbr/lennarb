# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

class Lennarb
	class RouteNode
		attr_accessor :static_children, :dynamic_children, :blocks, :param_key

		# Initializes the RouteNode class.
		#
		# @return [RouteNode]
		#
		def initialize
			@blocks           = {}
			@param_key        = nil
			@static_children  = {}
			@dynamic_children = {}
		end

		# Add a route to the route node
		#
		# @parameter parts       [Array<String>] The parts of the route
		# @parameter http_method [Symbol] The HTTP method of the route
		# @parameter block       [Proc] The block to be executed when the route is matched
		#
		# @return [void]
		#
		def add_route(parts, http_method, block)
			current_node = self

			parts.each do |part|
				if part.start_with?(':')
					param_sym = part[1..].to_sym
					current_node.dynamic_children[param_sym] ||= RouteNode.new
					dynamic_node = current_node.dynamic_children[param_sym]
					dynamic_node.param_key = param_sym
					current_node = dynamic_node
				else
					current_node.static_children[part] ||= RouteNode.new
					current_node = current_node.static_children[part]
				end
			end

			current_node.blocks[http_method] = block
		end

		def match_route(parts, http_method, params: {})
			if parts.empty?
				return [blocks[http_method], params] if blocks[http_method]
			else
				part = parts.first
				rest = parts[1..]

				if static_children.key?(part)
					result_block, result_params = static_children[part].match_route(rest, http_method, params:)
					return [result_block, result_params] if result_block
				end

				dynamic_children.each_value do |dyn_node|
					new_params = params.dup
					new_params[dyn_node.param_key] = part
					result_block, result_params = dyn_node.match_route(rest, http_method, params: new_params)

					return [result_block, result_params] if result_block
				end
			end

			[nil, nil]
		end
	end
end
