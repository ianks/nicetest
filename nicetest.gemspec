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
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.files = Dir["lib/**/*.rb", "exe/*", "LICENSE.txt", "README.md"]
  spec.bindir = "exe"
  spec.executables = ["nicetest"]
  spec.require_paths = ["lib"]

  spec.add_dependency("minitest", ">= 5.0")
  spec.add_dependency("minitest-focus", "~> 1.4")
  spec.add_dependency("minitest-reporters", "~> 1.4")
  spec.add_dependency("optparse", ">= 0.5.0") # since we override OptionParser#callback! temporarily
  spec.add_dependency("pastel", "~> 0.8")
  spec.add_dependency("super_diff", "~> 0.12")

  spec.cert_chain = ["certs/ianks.pem"]
  unless ENV["RUBYGEMS_FORCE_DISABLE_GEM_SIGNING"] == "true"
    spec.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0.end_with?("gem")
  end
end
