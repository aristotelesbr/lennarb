# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

class Lennarb
	module Plugin
		@plugins = {}

		# Register a plugin
		#
		# @parameter [String] name
		# @parameter [Module] mod
		#
		# @returns [void]
		#
		def self.register(name, mod)
			@plugins[name] = mod
		end

		# Load a plugin
		#
		# @parameter [String] name
		#
		# @returns [Module] plugin
		#
		def self.load(name)
			@plugins[name] || raise(LennarbError, "Plugin #{name} did not register itself correctly")
		end

		# @returns [Hash] plugins
		#
		def self.plugins = @plugins
	end
end
