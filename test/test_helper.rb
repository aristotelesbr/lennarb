# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

ENV['RACK_ENV'] = 'test'

# Set the console level to fatal
#
ENV['CONSOLE_LEVEL'] = 'fatal'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'lennarb'

# Require test helpers
#
require 'minitest/autorun'

# Require Rack::test
#
require 'rack/test'

# Default settigns for base class
#
module Minitest
	class Test
		def teardown
			Lenna::Middleware::App.instance.reset!
		end
	end
end

# Define the base test for request tests
#
class ApplicationRequest < Minitest::Test
	include Rack::Test::Methods

	def teardown
		Lenna::Middleware::App.instance.reset!
	end
end
