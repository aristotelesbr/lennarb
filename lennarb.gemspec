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

  spec.bindir = "exe"
  spec.executables = ["lenna"]
  spec.require_paths = ["lib"]

  spec.add_dependency "bigdecimal"
  spec.add_dependency "colorize", "~> 1.1"
  spec.add_dependency "rack", "~> 3.1"
  spec.add_dependency "superconfig"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-json"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-utils"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "standard-custom"
  spec.add_development_dependency "standard-performance"
  spec.add_development_dependency "m"
  spec.add_development_dependency "debug"
end
