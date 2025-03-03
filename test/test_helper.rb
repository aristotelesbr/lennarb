require "simplecov"
require "simplecov-json"

# Configure SimpleCov
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
]

SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"

  enable_coverage :branch

  track_files "lib/**/*.rb"
end

require "bundler/setup"
require "lennarb"
require "rack/test"

require "minitest/utils"
require "minitest/autorun"

Dir["#{__dir__}/support/**/*.rb"].each do |file|
  require file
end

module Minitest
  class Test
  end
end
