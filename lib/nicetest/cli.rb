# frozen_string_literal: true

module Nicetest
  class Cli
    PASTEL = Pastel.new

    BANNER = <<~BANNER
      ☀️  #{PASTEL.bold.cyan("nicetest")} #{PASTEL.dim.italic(Nicetest::VERSION)}

        A minimalistic test runner for Minitest.

      #{PASTEL.bold("Usage")}

        nicetest [options] [files or directories]

      #{PASTEL.bold("Examples")}

        $ nicetest
        $ nicetest test/models --reporter spec
        $ nicetest test/models/user_test.rb:12

      #{PASTEL.bold("Options")}

    BANNER

    def initialize(argv)
      @argv = argv
      @logger = Logger.new($stderr)
    end

    def run
      disable_autorun!
      adjust_load_path!

      args = @argv.dup
      argv_test_files = select_file_args(args)
      argv_test_files = glob_test_files("test") if argv_test_files.empty?
      args -= argv_test_files

      required_files = argv_test_files.flat_map do |file_or_dir|
        require_path_or_dir(file_or_dir)
      end

      @logger.fatal!("no test files found") if required_files.compact.empty?

      Minitest.run(args)
    end

    def select_file_args(args)
      args = args.dup
      Minitest.instance_variable_set(:@extensions, Set.new) # Avoid double-loading plugins
      Minitest.load_plugins unless args.delete("--no-plugins") || ENV["MT_NO_PLUGINS"]
      Minitest.process_args(args) # This will remove all the options from the args, leaving only the test files
      args
    end

    def glob_test_files(dir)
      Dir.glob("#{dir}/**{,/*/**}/*_test.rb")
    end

    def require_path_or_dir(path_or_dir)
      if path_or_dir.end_with?(".rb")
        [try_require(path_or_dir)]
      else
        Dir.glob("#{path_or_dir}/**{,/*/**}/*_test.rb").map do |f|
          try_require(f)
        end
      end
    end

    def try_require(path)
      full_path = File.expand_path(path)
      require full_path
      true
    rescue LoadError
      @logger.warn("could not require #{full_path}")
      nil
    end

    def disable_autorun!
      require "minitest"
      Minitest.class_variable_set(:@@installed_at_exit, true) # rubocop:disable Style/ClassVars
    end

    def adjust_load_path!
      $LOAD_PATH.unshift("test")
    end
  end
end
