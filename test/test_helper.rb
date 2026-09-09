ENV["APP_ENV"] = "test"
ENV["LENNARB_SILENT_LOGS"] = "true"

$stdout.sync = true

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
  add_filter "/lib/lennarb/version.rb"

  enable_coverage :branch

  track_files "lib/**/*.rb"
end

require "bundler/setup"
require "lennarb"
require "rack/test"

require "minitest/utils"
require "minitest/autorun"
# minitest 6 extracted Minitest::Mock and Object#stub into the minitest-mock
# gem; minitest 5 loaded them from autorun.
require "minitest/mock"

Dir["#{__dir__}/support/**/*.rb"].each do |file|
  require file
end

module Minitest
  class Test
  end
end
