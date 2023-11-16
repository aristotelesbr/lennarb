# frozen_string_literal: true

require_relative 'lib/lennarb/version'

Gem::Specification.new do |spec|
  spec.name = 'lennarb'
  spec.version = Lennarb::VERSION
  spec.license = 'MIT'
  spec.authors = ['Aristóteles Coutinho']
  spec.email = ['aristotelesbr@gmail.com']
  spec.summary = 'A lightweight and experimental web framework for Ruby.'
  spec.description = <<~EOF
    Lenna is a lightweight and experimental web framework for Ruby. It's designed to be modular and easy to use. Also, that's how I affectionately call my wife.
  EOF
  spec.homepage = 'https://rubygems.org/gems/lennarb'
  spec.required_ruby_version = '>= 3.2.0'
  spec.metadata['allowed_push_host'] = 'https://rubygems.org/gems/lennarb'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/aristotelesbr/lennarb'
  spec.metadata['changelog_uri'] = 'https://github.com/aristotelesbr/lennarb/blob/master/CHANGELOG.md'
  spec.files = Dir['lib/**/*']
  spec.extra_rdoc_files = %w[README.md LICENCE CHANGELOG.md]
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'puma', '~> 6.4'
  spec.add_dependency 'rack', '~> 3.0', '>= 3.0.8'
  spec.add_dependency 'rake', '~> 13.0', '>= 13.0.6'
  spec.add_dependency 'colorize', '~> 1.1'
  # Uncomment to register a new dependency of your gem
  spec.add_development_dependency 'minitest', '~> 5.20'
  spec.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
