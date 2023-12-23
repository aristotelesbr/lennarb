# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

ENV['RACK_ENV'] ||= 'development'

# Extension for Array class
#
require 'lennarb/array_extensions'

# Base class for Lennarb
#
require 'lenna/application'
require 'lennarb/version'

# Core extensions
#
require 'pathname'

# Lennarb module
#
module Lennarb
	module_function

	# Lennarb root path
	#
	# @return [Pathname] the root path
	#
	def root
		File.expand_path('..', __dir__)
		Pathname.new(File.expand_path('..', __dir__))
	end
end
