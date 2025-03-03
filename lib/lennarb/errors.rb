module Lennarb
  # Lite implementation of app.
  #
  Error = Class.new(StandardError)
  # This error is raised whenever the app is initialized more than once.
  #
  DuplicateRouteError = Class.new(StandardError)
  # This error is raised whenever the app is initialized more than once.
  #
  MissingEnvironmentVariable = Class.new(StandardError)
  # This error is raised whenever the app is initialized more than once.
  #
  MissingCallable = Class.new(StandardError)
end
