# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Run tests"
task :test do
  sh("exe/nicetest", "--reporter", "doc")
end

task default: [:test, :rubocop]
