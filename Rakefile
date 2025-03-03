require "bundler/gem_tasks"
require "standard/rake"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = false
end

namespace :coverage do
  desc "Validate code coverage meets minimum threshold (85%)"
  task :check do
    require "json"

    puts "Validating code coverage..."

    coverage_dir = "coverage"
    coverage_json = File.join(coverage_dir, "coverage.json")

    unless File.exist?(coverage_json)
      puts "Error: Coverage JSON data not found at #{coverage_json}."
      puts "Run tests with SimpleCov enabled first."
      exit 1
    end

    data = JSON.parse(File.read(coverage_json))
    percent = data["metrics"]["covered_percent"].to_f.round(2)

    puts "Coverage: #{percent}%"

    threshold = 85
    if percent < threshold
      puts "Coverage is below the required #{threshold}% threshold!"
      exit 1
    else
      puts "Coverage meets the required threshold. Good job!"
    end
  end
end

task default: :test
