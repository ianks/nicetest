# frozen_string_literal: true

require "pastel"
require "minitest/focus"

require_relative "nicetest/version"
require_relative "nicetest/logger"
require_relative "nicetest/cli"
require_relative "nicetest/backtrace_filter"
require_relative "nicetest/test_finder"
require_relative "nicetest/nicetest_plugin"
require_relative "nicetest/reporters_plugin"
require_relative "nicetest/superdiff_plugin"

module Nicetest
  class Error < StandardError; end

  class << self
    def logger
      @logger ||= Logger.new($stderr)
    end
  end
end
