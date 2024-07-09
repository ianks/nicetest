# frozen_string_literal: true

require_relative "lib/nicetest/version"

Gem::Specification.new do |spec|
  spec.name = "nicetest"
  spec.version = Nicetest::VERSION
  spec.authors = ["Ian Ker-Seymer"]
  spec.email = ["ian.kerseymer@shopify.com"]

  spec.summary = "A slightly fancier configuration for Minitest"
  spec.description = "Configure Minitest with common plugins and options to make it even nicer to use."
  spec.homepage = "https://github.com/ianks/nicetest"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "not yet"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  File.basename(__FILE__)
  spec.files = Dir["lib/**/*.rb", "exe/*", "LICENSE.txt", "README.md"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("minitest-reporters", "~> 1.4")
  spec.add_dependency("super_diff", "~> 0.12")
end
