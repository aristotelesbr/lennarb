# frozen_string_literal: true

require_relative 'lib/lennarb/version'

Gem::Specification.new do |spec|
	spec.name = 'lennarb'
	spec.version = Lennarb::VERSION

	spec.summary = 'A lightweight and experimental web framework for Ruby.'
	spec.authors = ['Aristóteles Coutinho']
	spec.license = 'MIT'

	spec.homepage = 'https://aristotelesbr.github.io/lennarb'

	spec.metadata = {
		'allowed_push_host' => 'https://rubygems.org/gems/lennarb',
		'changelog_uri' => 'https://github.com/aristotelesbr/lennarb/blob/master/changelog.md',
		'homepage_uri' => 'https://aristotelesbr.github.io/lennarb',
		'rubygems_mfa_required' => 'true',
		'source_code_uri' => 'https://github.com/aristotelesbr/lennarb'
	}

	spec.files = Dir['{exe,lib}/**/*', '*.md', base: __dir__]

	spec.bindir = 'exe'
	spec.executables = ['lenna']

	spec.required_ruby_version = '>= 3.1'

	spec.add_dependency 'colorize', '~> 1.1'
	spec.add_dependency 'rack', '~> 3.0', '>= 3.0.8'

	spec.add_development_dependency 'bake', '~> 0.18.2'
	spec.add_development_dependency 'bundler', '~> 2.2'
	spec.add_development_dependency 'covered', '~> 0.25.1'
	spec.add_development_dependency 'minitest', '~> 5.20'
	spec.add_development_dependency 'puma', '~> 6.4'
	spec.add_development_dependency 'rake', '~> 13.1'
	spec.add_development_dependency 'rack-test', '~> 2.1'
	spec.add_development_dependency 'rubocop', '~> 1.59'
	spec.add_development_dependency 'rubocop-minitest', '~> 0.33.0'
end
