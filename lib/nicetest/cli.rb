# frozen_string_literal: true

require "pastel"
require "minitest"
require "optparse"
require "English"
require "set"

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
      elsif File.exist?("Gemfile") && !File.read("Gemfile").include?("nicetest")
        run_in_directory(".")
      else
        run_tests(cli_options)
      end
    end

    def run_tests(cli_options = Opts.parse!(@argv))
      disable_autorun!
      adjust_load_path!

      args = @argv.dup
      argv_test_files = select_file_args(args)
      argv_test_files = glob_test_files("test") if argv_test_files.empty?
      args -= argv_test_files
      finder = TestFinder.new
      filters = Set.new

      if cli_options.name
        name = cli_options.name
        name = name[1..-1] if name.start_with?("/")
        name = name[0..-2] if name.end_with?("/")
        filters << name
      end

      required_files = argv_test_files.map do |pattern|
        file_or_dir, filter = finder.filter_for(pattern)
        filters << filter if filter && !cli_options.name
        require_path_or_dir(file_or_dir)
      end

      @logger.fatal!("no test files found") if required_files.compact.empty?
      args << "--name=/#{filters.to_a.join("|")}/" if filters.any?

      Minitest.run(args)
    end

    private

    def fetch_dep_loadpaths(gemspec, seen = {})
      return [] if seen[gemspec.name]

      seen[gemspec.name] = true
      load_paths = gemspec.full_require_paths

      gemspec.dependencies.each do |dep|
        dep_spec = Gem.loaded_specs[dep.name]
        next unless dep_spec

        load_paths.concat(fetch_dep_loadpaths(dep_spec, seen))
      end

      load_paths
    end

    def run_in_directory(input_dir)
      dir = File.expand_path(input_dir)
      dir.delete_suffix!("/") # remove trailing slash

      chdir = if input_dir != "."
        ->(&blk) do
          @logger.info("changing directory to #{dir}")
          Dir.chdir(dir, &blk)
        end
      else
        ->(&blk) { blk.call }
      end

      loadpaths = fetch_dep_loadpaths(Gem.loaded_specs["nicetest"]).map { |path| "-I#{path}" }
      requires = ["-rnicetest"]
      args_with_removed_leading_path = @argv.map do |arg|
        arg = arg.dup
        arg.delete_prefix!(dir)
        arg.delete_prefix!(File.expand_path(dir))
        arg.delete_prefix!("/")
        arg
      end

      run_proc = proc do
        requires << "-rbundler/setup" if File.exist?("Gemfile")

        cmd = [
          RbConfig.ruby,
          *loadpaths,
          *requires,
          "-e",
          "exit(Nicetest::Cli.new(ARGV).run_tests)",
          "--",
          *args_with_removed_leading_path,
        ]
        @logger.debug("running #{cmd.join(" ")}")
        system(*cmd)
        $CHILD_STATUS.exitstatus
      end

      chdir.call do
        if defined?(Bundler)
          Bundler.with_unbundled_env(&run_proc)
        else
          run_proc.call
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

    Opts = Struct.new(:cd, :name) do
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

            opts.on("-n", "--name=PATTERN", "Filter test names on pattern") do |pattern|
              options[:name] = pattern
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
