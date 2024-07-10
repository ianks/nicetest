# frozen_string_literal: true

require "test_helper"
require "super_diff"
require "minitest/superdiff_plugin"

module Minitest
  class SuperdiffPluginTest < Minitest::Test
    def setup
      @subject = Class.new(Minitest::Test) { include Minitest::SuperdiffPlugin }.new(self.class.name)
      super
    end

    def test_assert_equal
      @subject.assert_equal({ "a" => 1, "b" => 2 }, { "a" => 1, "b" => 3 })
    rescue Minitest::Assertion => e
      assert_equal(
        "Differing hashes.\n\n\e[35mExpected: { \"a\" => 1, \"b\" => 2 }\e[0m\n" \
          "\e[33m  Actual: { \"a\" => 1, \"b\" => 3 }\e[0m\n\nDiff:\n\n  {\n    \"a\" => 1,\n" \
          "\e[35m-   \"b\" => 2\e[0m\n\e[33m+   \"b\" => 3\e[0m\n  }",
        e.message,
      )
    end

    def test_assert_includes_array
      @subject.assert_includes([1, 2, 3], 4)
    rescue Minitest::Assertion => e
      assert_equal(
        "Expected \e[35m[1, 2, 3]\e[0m to include \e[33m4\e[0m, but it did not.\n\n\n" \
          "Diff:\n\n  [\n    1,\n    2,\n    3,\n\e[33m+   4\e[0m\n  ]",
        e.message,
      )
    end

    def test_assert_includes_hash
      @subject.assert_includes({ a: 1, b: 2 }, :c)
    rescue Minitest::Assertion => e
      assert_equal(
        "Expected collection to include item but it did not.\n\n" \
          "\e[35m  Collection: { a: 1, b: 2 }\e[0m\n\e[33mMissing item: :c\e[0m",
        e.message,
      )
    end
  end
end
