# frozen_string_literal: true

module Minitest
  class << self
    def plugin_superdiff_options(opts, options)
      opts.on("--no-superdiff", "Disable superdiff") do
        options[:no_superdiff] = true
      end
    end

    def plugin_superdiff_init(options)
      return if options[:no_superdiff]

      require "super_diff"
      Minitest::Assertions.prepend(Nicetest::SuperdiffPlugin)
    end
  end
end

module Nicetest
  module SuperdiffPlugin
    module Helpers
      extend self

      def inspect_styled(obj, style, prefix: nil)
        obj = SuperDiff.inspect_object(obj, as_lines: false)
        SuperDiff::Core::Helpers.style(style, "#{prefix}#{obj}")
      end
    end

    def diff(expected, actual)
      SuperDiff::EqualityMatchers::Main.call(expected: expected, actual: actual)
    end

    def mu_pp(obj)
      SuperDiff.inspect_object(obj, as_lines: false)
    end

    def assert_includes(collection, item, message = nil)
      super
    rescue Minitest::Assertion => e
      raise if message

      exception = Minitest::Assertion.new(AssertIncludesMessage.new(collection: collection, item: item))
      exception.set_backtrace(e.backtrace)
      raise exception
    end

    class AssertIncludesMessage
      include SuperdiffPlugin::Helpers

      def initialize(collection:, item:)
        @collection = collection
        @item = item
      end

      def to_s
        return @to_s if defined?(@to_s)

        content = if (diff = optional_diff)
          collection = inspect_styled(@collection, :expected)
          item = inspect_styled(@item, :actual)

          <<~OUTPUT.strip
            Expected #{collection} to include #{item}, but it did not.

            #{diff}
          OUTPUT
        else
          expected = inspect_styled(@collection, :expected, prefix: "  Collection: ")
          actual = inspect_styled(@item, :actual, prefix: "Missing item: ")

          <<~OUTPUT.strip
            Expected collection to include item but it did not.

            #{expected}
            #{actual}
          OUTPUT
        end

        @to_s ||= content
      end

      def optional_diff
        case @collection
        when Array, Set
          collection_with_item = @collection + [@item].flatten(1)
          basic_diff(@collection, collection_with_item)
        end
      end

      def basic_diff(expected, actual)
        content = SuperDiff.diff(expected, actual)
        "\nDiff:\n\n#{content}"
      end
    end
  end
end
