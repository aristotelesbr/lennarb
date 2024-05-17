# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

class Lennarb
	module Plugin
		@plugins = {}

		def self.register(name, mod)
			@plugins[name] = mod
		end

		def self.load(name)
			@plugins[name] || raise("Plugin #{name} did not register itself correctly")
		end

		def self.plugins = @plugins
	end
end
