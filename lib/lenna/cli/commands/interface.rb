# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

module Lenna
	module Cli
		module Commands
			module Interface
				def self.execute(args)
					raise NotImplementedError
				end
			end
		end
	end
end
