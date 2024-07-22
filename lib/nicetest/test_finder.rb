# frozen_string_literal: true

require "prism"
require "set"

module Nicetest
  class TestFinder
    def initialize
      @parse_cache = {}
    end

    def filter_for(target)
      filename, lineno = target.split(":", 2)
      filepath = File.expand_path(filename)
      lineno = lineno&.to_i

      return [filepath, nil] unless lineno

      [filepath, find_test(filepath, lineno)]
    end

    private

    def find_test(filename, lineno)
      range_finder = @parse_cache[filename] ||= RangeFinder.parse_file(filename)
      range_finder.nearest_test_for_line(lineno)
    rescue => e
      Nicetest.logger.warn("Failed to parse #{filename} (#{e.class}: #{e.message})")
      nil
    end

    class RangeFinder < Prism::Compiler
      class << self
        def parse_file(filename)
          node = Prism.parse_file(filename)
          new(filename).populate(node.value)
        end
      end

      attr_reader :scopes

      def initialize(filename)
        super()
        @namespace_stack = []
        @class_scopes = []
        @tests = []
        @program_nodes = []
        @scopes = []
      end

      def populate(node)
        visit(node)
        @scopes += @tests
        @scopes += @class_scopes
        self
      end

      def nearest_test_for_line(lineno)
        found = @scopes.find do |range, _test_name|
          range.cover?(lineno)
        end
        found&.last
      end

      def visit_program_node(node)
        @program_nodes << node
        ret = super

        if (last_scope = @class_scopes.last)
          @class_scopes << [last_scope[0].end..node.location.end_line, last_scope[1]]
        end

        ret
      end

      def visit_module_node(node)
        @namespace_stack.push(node)
        super
        @namespace_stack.pop
      end

      def visit_class_node(node)
        @namespace_stack.push(node)
        super
        @namespace_stack.pop
      end

      def visit_def_node(node)
        node_name = node.name.to_s
        return super unless node_name.start_with?("test_")

        @tests << [test_range_for(node.location), test_id_for(node_name)]
      end

      def visit_call_node(node)
        return super unless node.name == :test

        test_name = "test_#{node.arguments.arguments.first.unescaped}"
        test_name.gsub!(/\s+/, "_")
        @tests << [test_range_for(node.location), test_id_for(test_name)]
      end

      def test_id_for(test_name)
        "#{@namespace_stack.map(&:name).join("::")}##{test_name}"
      end

      def test_range_for(location)
        if @tests.empty?
          current_nesting = @namespace_stack.map(&:name).join("::")
          @class_scopes << [0..(location.start_line - 1), current_nesting]
        end

        last_scope = @tests.last || @class_scopes.last
        last_scope_start = last_scope[0].begin
        last_scope[0] = last_scope_start..(location.start_line - 1)

        location.start_line..location.end_line
      end
    end
  end
end
