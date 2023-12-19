# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

module Lenna
	class Router
		# This class is responsible for matching the request path
		#   to an endpoint and executing the endpoint action.
		#
		# @private Since `v0.1.0`
		#
		# This will match the request path to an endpoint and execute
		# the endpoint action.
		#
		class RouteMatcher
			# @parameter root_node [Lenna::Node] The root node
			#
			def initialize(root_node) = @root_node = root_node

			# This method will match the request path to an endpoint and execute
			# the endpoint action.
			#
			# @parameter req [Lenna::Request]  The request object
			# @parameter res [Lenna::Response] The response object
			# @return        [Lenna::Response] The response object
			#
			def match_and_execute_route(req, res)
				params = {}
				path_parts = split_path(req.path_info)
				endpoint = find_endpoint(@root_node, path_parts, params)

				if endpoint && (action = endpoint[req.request_method])
					req.assign_params(params)
					action.call(req, res)
				else
					res.not_found
				end
			end

			private

			def split_path(path) = path.split('/').reject(&:empty?)

			# @parameter node   [Lenna::Node] The node to search
			# @parameter parts  [Array]       The path parts
			# @parameter params [Hash]        The params hash
			#
			# @return       [Lenna::Node] The node that matches the path
			#
			# This method is recursive.
			#
			def find_endpoint(node, parts, params)
				return node.endpoint if parts.empty?

				part = parts.shift
				child_node = node.children[part]

				if child_node.nil? && (placeholder_node = node.children[:placeholder])
					params[placeholder_node.placeholder_name] = part
					child_node = placeholder_node
				end

				find_endpoint(child_node, parts, params) if child_node
			end
		end
	end
end
