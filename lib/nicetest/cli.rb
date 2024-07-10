# frozen_string_literal: true

require "pastel"
require "minitest"
require "optparse"
require "English"

module Nicetest
  class Cli
    def initialize(argv)
      @argv = argv
      @logger = Logger.new($stderr)
    end

    def run
      cli_options = Opts.parse!(@argv)
      if (dir = cli_options.cd)
        run_in_directory(dir)
      else
        run_tests
      end
    end

    private

    def fetch_dep_loadpaths(gemspec, seen = {})
      return [] if seen[gemspec.name]

      seen[gemspec.name] = true
      load_paths = gemspec.load_paths

      gemspec.dependencies.each do |dep|
        dep_spec = Gem.loaded_specs[dep.name]
        next unless dep_spec

        load_paths.concat(fetch_dep_loadpaths(dep_spec, seen))
      end

      load_paths
    end

    def run_tests
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

    def run_in_directory(dir)
      dir = File.expand_path(cli_options.cd)
      dir.delete_suffix!("/") # remove trailing slash

      @logger.info("changing directory to #{dir}")
      loadpaths = fetch_dep_loadpaths(Gem.loaded_specs["nicetest"]).map { |path| "-I#{path}" }
      requires = ["-rnicetest"]
      args_with_removed_leading_path = @argv.map do |arg|
        arg = arg.dup
        arg.delete_prefix!(dir)
        arg.delete_prefix!(File.expand_path(dir))
        arg.delete_prefix!("/")
        arg
      end

      Dir.chdir(dir) do
        Bundler.with_unbundled_env do
          requires << "-rbundler/setup" if File.exist?("Gemfile")

          system(
            RbConfig.ruby,
            *loadpaths,
            *requires,
            "-e",
            "exit(Nicetest::Cli.new(ARGV).run)",
            *args_with_removed_leading_path,
          )
          $CHILD_STATUS.exitstatus
        end
      end
    end

    def select_file_args(args)
      args = args.dup
      Minitest.instance_variable_set(:@extensions, Set.new) # Avoid double-loading plugins
      Minitest.load_plugins unless args.delete("--no-plugins") || ENV["MT_NO_PLUGINS"]
      # this will remove all options from the args array
      temporarily_disable_optparse_callbacks { Minitest.process_args(args) }
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
    rescue => e
      bt = e.backtrace.first(10).map { |line| "\t#{PASTEL.dim(line)}" }.join("\n")
      @logger.warn("could not require #{full_path} (#{e.class}: #{e.message})\n#{bt}")
      nil
    end

    def disable_autorun!
      Minitest.class_variable_set(:@@installed_at_exit, true) # rubocop:disable Style/ClassVars
    end

    def adjust_load_path!
      $LOAD_PATH.unshift(File.expand_path("test"))
    end

    def temporarily_disable_optparse_callbacks(&blk)
      OptionParser.class_eval do
        def noop_callback!(*); end

        original_callback = instance_method(:callback!)
        define_method(:callback!, instance_method(:noop_callback!))

        yield

        define_method(:callback!, original_callback)
        remove_method(:noop_callback!)
      end
    end

    Opts = Struct.new(:cd) do
      class << self
        def parse!(argv)
          old_officious = OptionParser::Officious.dup
          OptionParser::Officious.clear

          options = new
          parser = OptionParser.new do |opts|
            opts.banner = ""
            opts.raise_unknown = false
            opts.on("--cd=DIR", "Change directory before running tests") do |dir|
              options[:cd] = dir
            end
          end

          parser.parse!(argv)
          OptionParser::Officious.replace(old_officious)
          options
        end
      end
    end

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

      #{PASTEL.bold("Nicetest Options")}
        --cd=DIR  Change directory before running tests
      #{PASTEL.bold("Minitest Options")}

    BANNER
  end
end
