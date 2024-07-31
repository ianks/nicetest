# frozen_string_literal: true

module Nicetest
  module ReportersPlugin
    MAPPING = {
      "none" => ->(_options) { nil },
      "default" => ->(options) { Minitest::Reporters::DefaultReporter.new(io: options[:io]) },
      "spec" => ->(options) { Minitest::Reporters::SpecReporter.new(io: options[:io]) },
      "doc" => ->(options) { MAPPING["spec"].call(options) },
      "junit" => ->(options) {
        ENV["MINITEST_REPORTERS_REPORTS_DIR"] ||= "tmp/nicetest/junit/#{Time.now.to_i}"
        Minitest::Reporters::JUnitReporter.new(io: options[:io])
      },
      "progress" => ->(options) { Minitest::Reporters::ProgressReporter.new(io: options[:io]) },
    }

    class << self
      def minitest_plugin_options(opts, options)
        options[:reporters] = ["progress"]

        vals = MAPPING.keys.join(",")
        description = <<~DESC.strip
          The reporters to use for test output as comma-seperated list.
        DESC

        opts.on("-r", "--reporter #{vals}", Array, description) do |reporters|
          reporters = options[:reporters] + reporters if reporters == ["junit"]

          is_subset = (reporters - MAPPING.keys).empty?
          raise OptionParser::InvalidArgument, "Invalid reporter: #{reporters.join(", ")}" unless is_subset

          options[:reporters] = reporters
        end
      end

      def minitest_plugin_init(options)
        return if options[:reporters].nil? || options[:reporters].empty?

        require "minitest/reporters"

        reporters = options[:reporters].map do |reporter|
          MAPPING.fetch(reporter).call(options)
        end.compact

        Minitest::Reporters.use!(reporters, ENV, Minitest.backtrace_filter) unless reporters.empty?
      end
    end
  end
end
