# frozen_string_literal: true

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
