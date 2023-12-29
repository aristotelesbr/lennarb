# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

module Lenna
	module Cli
		module Commands
			module Interface
				def new(args)
					raise NotImplementedError
				end

				def call
					raise NotImplementedError
				end
			end
		end
	end
end
