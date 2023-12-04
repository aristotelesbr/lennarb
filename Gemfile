# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in lennarb.gemspec
gemspec

# [https://rubygems.org/gems/puma]
# Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for
# Ruby/Rack applications. Puma is intended for use in both development and
# production environments. In order to get the best throughput, it is highly
# recommended that you use a Ruby implementation with real threads like Rubinius
# or JRuby.
gem 'puma', '~> 6.4'
# [https://rubygems.org/gems/rack]
# Rack provides a minimal, modular, and adaptable interface for developing web
# applications in Ruby. By wrapping HTTP requests and responses in the simplest
# way possible, it unifies and distills the API for web servers, web frameworks,
# and software in between (the so-called middleware) into a single method call.
gem 'rack', '~> 3.0', '>= 3.0.8'
# [https://rubygems.org/gems/colorize]
# Colorize is a Ruby gem used to color text in terminals.
gem 'colorize', '~> 1.1'

group :development, :test do
  # [https://rubygems.org/gems/rake]
  # Rake is a Make-like program implemented in Ruby. Tasks and dependencies are
  # specified in standard Ruby syntax.
  gem 'rake', '~> 13.0', '>= 13.0.6'
  # [https://rubygems.org/gems/rubocop]
  # Automatic Ruby code style checking tool. Aims to enforce the
  # community-driven Ruby Style Guide.
  gem 'rubocop', '~> 1.57', '>= 1.57.2'
  # [https://rubygems.org/gems/minitest-pride]
  # Automatic Minitest code style checking tool. A RuboCop extension focused on
  # enforcing Minitest best practices and coding conventions.
  gem 'rubocop-minitest', '~> 0.33.0'
  # [https://rubygems.org/gems/minitest]
  # Minitest provides a complete suite of testing facilities supporting TDD,
  # BDD, mocking, and benchmarking.
  gem 'minitest', '~> 5.20'
  # [https://rubygems.org/gems/rack-test]
  # Rack::Test is a small, simple testing API for Rack apps. It can be used on
  # its own or as a reusable starting point for Web frameworks and testing
  # libraries to build on.
  gem 'rack-test', '~> 2.1'
end
