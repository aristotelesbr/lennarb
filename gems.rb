source "https://rubygems.org"

# Specify your gem's dependencies in lennarb.gemspec
gemspec

group :maintenance, optional: true do
  # [https://rubygems.org/gems/bake-gem]
  # Bake Gem is a Bake extension that helps you to create a new Ruby
  # gem.
  gem "bake-gem"
  # [https://rubygems.org/gems/bake-modernize]
  # Bake Modernize is a Bake extension that helps you to modernize your
  # Ruby code.
  gem "bake-modernize"
  # [https://rubygems.org/gems/bake-github-pages]
  # Bake Github Pages is a Bake extension that helps you to publish your
  # project documentation to Github Pages.
  gem "bake-github-pages"
  # [https://rubygems.org/gems/utpia-project]
  # Utopia Project is a Bake extension that helps you to create a new
  # project.
  gem "utopia-project"
end
