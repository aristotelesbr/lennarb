# frozen_string_literal: true

require_relative 'lib/lennarb/version'

Gem::Specification.new do |spec|
  spec.name = 'lennarb'
  spec.version = Lennarb::VERSION
  spec.authors = ['Aristóteles Coutinho']
  spec.email = ['aristotelesbr@gmail.com']
  spec.summary = "A modular web framework for Ruby."
  spec.description = <<~EOF
    Lenna is a lightweight, fast and easy framework for building modular
    web applications and APIS with Ruby. Also, that's how I affectionately call my wife.
  EOF
  spec.homepage = 'https://rubygems.org/gems/lennarb'
  spec.required_ruby_version = '>= 2.7.0'
  spec.metadata['allowed_push_host'] = 'https://rubygems.org/gems/lennarb'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/aristotelesbr/lennarb'
  spec.metadata['changelog_uri'] = 'https://github.com/aristotelesbr/lennarb/blob/master/CHANGELOG.md'
  spec.files = Dir['lib/**/*'] + %w[MIT-LICENSE README.md SPEC.rdoc]
  spec.extra_rdoc_files = ['README.md', 'CHANGELOG', 'CONTRIBUTING.md']
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_development_dependency 'minitest', "~> 5.20"
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
