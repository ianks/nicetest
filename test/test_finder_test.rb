# frozen_string_literal: true

require "test_helper"

class TestFinderTest < Minitest::Test
  def test_find_single_test_in_basic_file
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/basic.rb:4")

    assert_equal("MyTest#test_truth", filter)
  end

  def test_first_line_in_file_returns_class_name
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/basic.rb:1")

    assert_equal("MyTest", filter)
  end

  def test_first_line_in_file_returns_class_names_in_moduled_file
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/moduled.rb:1")

    assert_equal("MyModule::MyTest", filter)
  end

  def test_in_between_lines_in_basic_file
    # Ensure test is valid
    lineno = 7
    assert_equal(File.readlines("test/fixtures/test_files/basic.rb")[lineno - 1], "\n")
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/basic.rb:#{lineno}")

    assert_equal("MyTest#test_truth", filter)
  end

  def test_last_line_in_file_returns_class
    line_count = File.readlines("test/fixtures/test_files/basic.rb").count
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/basic.rb:#{line_count}")

    assert_equal("MyTest", filter)
  end

  def test_moduled_test_file_returns_class_name
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/moduled.rb:4")

    assert_equal("MyModule::MyTest", filter)
  end

  def test_moduled_test_file_returns_method
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/moduled.rb:6")

    assert_equal("MyModule::MyTest#test_truth", filter)
  end

  def test_moduled_in_between_lines
    # Ensure test is valid
    lineno = 8
    assert_equal(File.readlines("test/fixtures/test_files/moduled.rb")[lineno - 1], "\n")
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/moduled.rb:#{lineno}")

    assert_equal("MyModule::MyTest#test_truth", filter)
  end

  def test_declarative_test_file_returns_class_name
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/declarative.rb:4")

    assert_equal("MyModule::MyTest", filter)
  end

  def test_declarative_test_file_returns_declarative_test
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/declarative.rb:5")

    assert_equal("MyModule::MyTest#test_does_SOMETHING_useful_#1", filter)
  end

  def test_declarative_test_file_returns_actual_method
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/declarative.rb:9")

    assert_equal("MyModule::MyTest#test_something", filter)
  end

  def test_declarative_test_file_returns_declarative_test_2
    finder = Nicetest::TestFinder.new
    _, filter = finder.filter_for("test/fixtures/test_files/declarative.rb:14")

    assert_equal("MyModule::MyTest#test_does_SOMETHING_useful_#2", filter)
  end
end
