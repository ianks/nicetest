# frozen_string_literal: true

module MyModule
  class MyTest < Minitest::Test
    def test_truth
      assert(true)
    end

    def test_falsehood
      refute(false)
    end

    def test_error
      assert_raises(StandardError) do
        raise StandardError
      end
    end
  end
end
