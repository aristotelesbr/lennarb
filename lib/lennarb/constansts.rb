module Lennarb
  # The root app directory of the app.
  RACK_LENNA_APP = "lennarb.app"
  # The application base for the standard application
  RACK_LENNA_BASE = "lennarb.base"
  # The current environment. Defaults to "development".
  ENV_NAMES = %w[LENNA_ENV APP_ENV RACK_ENV]
  # The HTTP methods.
  HTTP_METHODS = %i[GET POST PUT PATCH DELETE HEAD OPTIONS]
  # The HTTP status codes.
  CONTENT_TYPE = {HTML: "text/html", TEXT: "text/plain", JSON: "application/json"}
  # The current environment. Defaults to "development".
  NAMES = %i[development test production local]
end
