source "https://rubygems.org"

# Specify your gem's dependencies in lennarb.gemspec
gemspec

group :maintenance, optional: true do
  # Yard is a documentation generation tool for the Ruby programming language.
  # [https://rubygems.org/gems/yard]
  gem "yard"
end
