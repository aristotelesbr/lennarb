require_relative "lib/lennarb/version"

Gem::Specification.new do |spec|
  spec.name = "lennarb"
  spec.version = Lennarb::VERSION

  spec.summary = <<~DESC
    Lennarb provides a lightweight yet robust solution for web routing in Ruby, focusing on performance and simplicity.
  DESC
  spec.authors = ["Aristóteles Coutinho"]
  spec.license = "MIT"
  spec.homepage = "https://aristotelesbr.github.io/lennarb"
  spec.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "changelog_uri" => "https://github.com/aristotelesbr/lennarb/blob/master/changelog.md",
    "homepage_uri" => "https://aristotelesbr.github.io/lennarb",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/aristotelesbr/lennarb"
  }

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.match(%r{^(test|features)/}) }
  end

  # lib/lennarb/routes.rb uses `it`, the implicit block parameter, which is
  # Ruby 3.4+. Without this, RubyGems installs happily on an older Ruby and the
  # first require fails with a SyntaxError instead of a clear resolution error.
  spec.required_ruby_version = ">= 3.4"

  spec.bindir = "exe"
  spec.executables = ["lenna"]
  spec.require_paths = ["lib"]

  spec.add_dependency "bigdecimal"
  spec.add_dependency "colorize", "~> 1.1"
  spec.add_dependency "rack", "~> 3.1"
  spec.add_dependency "superconfig", "~> 3.0"
  spec.add_dependency "logger", "~> 1.7"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-json"
  # Pinned to the major: minitest 6 removed Minitest::Mock and Object#stub, which
  # silently broke CI for five months because nothing pins and gems.locked is
  # gitignored. A major bump must be a deliberate change, not a fresh resolve.
  spec.add_development_dependency "minitest", "~> 6.0"
  # minitest 6 extracted Minitest::Mock and Object#stub into their own gem.
  spec.add_development_dependency "minitest-mock", "~> 5.27"
  spec.add_development_dependency "minitest-utils"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "standard-custom"
  spec.add_development_dependency "standard-performance"
  spec.add_development_dependency "debug" if RUBY_ENGINE == "ruby"
end
