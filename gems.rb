# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

source 'https://rubygems.org'

# Specify your gem's dependencies in lennarb.gemspec
gemspec

# [https://rubygems.org/gems/rack]
# Rack provides a minimal, modular, and adaptable interface for developing web
# applications in Ruby. By wrapping HTTP requests and responses in the simplest
# way possible, it unifies and distills the API for web servers, web frameworks,
# and software in between (the so-called middleware) into a single method call.
gem 'rack', '~> 3.0', '>= 3.0.8'
# [https://rubygems.org/gems/colorize]
# Colorize is a Ruby gem used to color text in terminals.
gem 'colorize', '~> 1.1'

group :maintenance, optional: true do
	# [https://rubygems.org/gems/bake-gem]
	# Bake Gem is a Bake extension that helps you to create a new Ruby
	# gem.
	gem 'bake-gem'
	# [https://rubygems.org/gems/bake-modernize]
	# Bake Modernize is a Bake extension that helps you to modernize your
	# Ruby code.
	gem 'bake-modernize'
	# [https://rubygems.org/gems/bake-github-pages]
	# Bake Github Pages is a Bake extension that helps you to publish your
	# project documentation to Github Pages.
	gem 'bake-github-pages'
	# [https://rubygems.org/gems/utpia-project]
	# Utopia Project is a Bake extension that helps you to create a new
	# project.
	gem 'utopia-project'
end

group :development, :test do
	# [https://rubygems.org/gems/covered]
	# Covered is a simple code coverage tool for Ruby.
	gem 'covered', '~> 0.25.1'
	# [https://rubygems.org/gems/bake]
	# Bake is a build tool for Ruby projects. It is designed to be simple,
	# fast and extensible.
	# [https://rubygems.org/gems/puma]
	gem 'bake', '~> 0.18.2'
	# Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for
	# Ruby/Rack applications.
	gem 'puma', '~> 6.4'
	# RuboCop is a Ruby code style checking and code formatting tool. It aims to
	# enforce the community-driven Ruby Style Guide.
	# [https://rubygems.org/gems/rubocop]
	gem 'rubocop', '~> 1.59', require: false
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
	# [https://rubygems.org/gems/rake]
	# Rake is a Make-like program implemented in Ruby. Tasks and dependencies are
	# specified in standard Ruby syntax. Rake has the following features:
	gem 'rake', '~> 13.1'
end
