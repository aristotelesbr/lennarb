# frozen_string_literal: true

# Set the environment to test
#
ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'lennarb'

require 'minitest/autorun'
