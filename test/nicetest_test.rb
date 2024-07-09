# frozen_string_literal: true

require "test_helper"

class TestNicetest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil(::Nicetest::VERSION)
  end
end
