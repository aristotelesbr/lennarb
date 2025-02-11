require "simplecov"
SimpleCov.start

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
