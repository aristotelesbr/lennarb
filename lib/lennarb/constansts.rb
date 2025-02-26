module Lennarb
  RACK_LENNA_APP = "lennarb.app"
  ENV_NAMES = %w[LENNA_ENV APP_ENV RACK_ENV]
  HTTP_METHODS = %i[GET POST PUT PATCH DELETE HEAD OPTIONS]
  CONTENT_TYPE = {HTML: "text/html", TEXT: "text/plain", JSON: "application/json"}
end
