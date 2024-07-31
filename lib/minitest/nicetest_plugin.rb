# frozen_string_literal: true

# opts.banner = "Usage: example.rb [options]"
require "nicetest"

module Minitest
  class << self
    def plugin_nicetest_options(opts, options)
      opts.banner = ::Nicetest::Cli::BANNER
      Nicetest::NicetestPlugin::ValidateMinitestFocus.apply!
    end

    def plugin_nicetest_init(_options)
      Minitest.backtrace_filter = Nicetest::BacktraceFilter.new
    end
  end
end

module Nicetest
  module NicetestPlugin
    module ValidateMinitestFocus
      class << self
        def apply!
          if ENV["CI"]
            Minitest::Test.singleton_class.prepend(ValidateMinitestFocus::NoFocus)
          end
        end
      end

      module NoFocus
        def focus(name = nil)
          location = caller_locations(1, 1).first
          Nicetest.logger.fatal!("cannot use `focus` in CI (#{location.path}:#{location.lineno})")
        end
      end
    end
  end
end
