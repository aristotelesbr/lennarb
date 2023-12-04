# frozen_string_literal: true

# Set the environment to test
#
ENV['RACK_ENV'] = 'test'

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
