# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'lennarb'

# Require test helpers
#
require 'minitest/autorun'

# Require Rack::test
#
require 'rack/test'
