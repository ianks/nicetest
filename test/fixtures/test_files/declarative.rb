# frozen_string_literal: true

module MyModule
  class MyTest < Minitest::Test
    test "does SOMETHING useful #1" do
      assert(true)
    end

    def test_something
      assert(true)
    end

    test "does SOMETHING useful #2" do
      refute(false)
    end
  end
end
