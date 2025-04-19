# Core extensions
#
require "bundler"
require "rack"
require "json"
require "pathname"
require "logger"
require "securerandom"
require "colorize"
require "superconfig"

# Lennarb is a lightweight Ruby web framework based on Rack that offers a high-performance solution for web development. Focused on simplicity, Lennarb delivers essential functionality without unnecessary complexity.
# Available in two versions:
#
# Lennarb::App: Minimal version. Includes only the core components, such as request, response, and route handling.
#
# Lennarb::Application: Standard version. Include common features like middleware, request handler, and more.
#
module Lennarb
  require_relative "lennarb/constants"
  require_relative "lennarb/environment"
  require_relative "lennarb/version"
  require_relative "lennarb/request"
  require_relative "lennarb/response"
  require_relative "lennarb/route_node"
  require_relative "lennarb/routes"
  require_relative "lennarb/config"
  require_relative "lennarb/errors"
  require_relative "lennarb/middleware_stack"
  require_relative "lennarb/helpers"
  require_relative "lennarb/hooks"
  require_relative "lennarb/request_handler"
  require_relative "lennarb/base"
  require_relative "lennarb/app"

  # Middlewares
  require_relative "lennarb/logger"
  require_relative "lennarb/parameter_filter"
  require_relative "lennarb/middleware/request_logger"
end
