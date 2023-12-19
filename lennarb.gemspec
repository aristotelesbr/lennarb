# frozen_string_literal: true

require_relative 'lib/lennarb/version'

Gem::Specification.new do |spec|
	spec.name = 'lennarb'
	spec.version = Lennarb::VERSION

	spec.summary = 'A lightweight and experimental web framework for Ruby.'
	spec.authors = ['Aristóteles Coutinho']
	spec.license = 'MIT'

	spec.homepage = 'https://rubygems.org/gems/lennarb'

	spec.metadata = {
		'allowed_push_host' => 'https://rubygems.org/gems/lennarb',
		'changelog_uri' => 'https://github.com/aristotelesbr/lennarb/blob/master/CHANGELOG.md',
		'homepage_uri' => 'https://rubygems.org/gems/lennarb',
		'rubygems_mfa_required' => 'true',
		'source_code_uri' => 'https://github.com/aristotelesbr/lennarb'
	}

	spec.files = Dir['{lib}/**/*', '*.md', base: __dir__]

	spec.required_ruby_version = '>= 3.0'

	spec.add_dependency 'colorize', '~> 1.1'
	spec.add_dependency 'puma', '~> 6.4'
	spec.add_dependency 'rack', ['~> 3.0', '>= 3.0.8']
	spec.add_dependency 'rake', ['~> 13.0', '>= 13.0.6']
end
