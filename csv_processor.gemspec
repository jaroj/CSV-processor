# frozen_string_literal: true

require_relative "lib/csv_processor/version"

Gem::Specification.new do |spec|
  spec.name = "csv_processor"
  spec.version = CSVProcessor::VERSION
  spec.authors = ["Jarek Jeleniewicz"]
  spec.email = ["jarojele@gmail.com"]

  spec.summary = "A configurable CSV processing pipeline with composable transform and validation rules."
  spec.description = "Process CSV records through a configurable pipeline of transform and validation rules. " \
                     "Errors are collected across all rules rather than stopping on the first failure."
  spec.homepage = "https://github.com/jaroj/CSV-processor"
  spec.required_ruby_version = ">= 3.3"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "csv"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
