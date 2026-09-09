module Lennarb
  # Base class for errors raised by Lennarb.
  #
  Error = Class.new(StandardError)
  # Raised when merging routes would define the same HTTP method twice for the
  # same path.
  #
  DuplicateRouteError = Class.new(StandardError)
  # Raised when a mandatory configuration value has no environment variable set.
  #
  MissingEnvironmentVariable = Class.new(StandardError)
  # Raised when a configuration property is declared without something callable
  # to compute it.
  #
  MissingCallable = Class.new(StandardError)
  # Raised when a route is registered after the routes have been frozen.
  #
  RoutesFrozenError = Class.new(RuntimeError)
end
