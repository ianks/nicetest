# frozen_string_literal: true

require "pastel"

module Nicetest
  class BacktraceFilter
    BUNDLER_REGEX = %r{/bundler/gems}
    GEMS_DEFAULT_DIR = Regexp.escape(Gem.default_dir)
    GEMS_PATHS = Gem.path.map { |path| Regexp.new(Regexp.escape(path)) }

    attr_reader :pastel

    def initialize
      @pastel = Cli::PASTEL
      @silence_pattern = Regexp.union([
        /sorbet-runtime/,
        Regexp.escape(RbConfig::CONFIG["rubylibdir"]),
        %r{/gems/bundler-\d+\.\d+\.\d+/lib/bundler},
        %r{/gems/minitest-\d+\.\d+\.\d+/lib/minitest},
        %r{/gems/minitest-reporters-\d+\.\d+\.\d+/lib/minitest},
        %r{(bin|exe)/bundle:},
        /internal:warning/,
      ])
      @dim_pattern = Regexp.union([
        GEMS_DEFAULT_DIR,
        *GEMS_PATHS,
        BUNDLER_REGEX,
      ])
    end

    def filter(backtrace)
      bt = []
      first_line = true
      cwd = Dir.pwd

      backtrace.each do |line|
        silenced = silence?(line)

        next if silenced && !first_line

        first_line = false

        bt << if silenced || (dim?(line) && !line.start_with?(cwd))
          pastel.dim(trim_prefix(line))
        else
          colorize_line(trim_prefix(line))
        end
      end

      bt
    end

    def dim?(line)
      @dim_pattern.match?(line)
    end

    def silence?(line)
      @silence_pattern.match?(line)
    end

    def trim_prefix(line)
      line = line.delete_prefix(Dir.pwd + "/")
      line.sub!(ENV["HOME"], "~")
      line
    end

    def colorize_line(line)
      match = line.match(/(.*):(\d+):in `(.*)'/)

      if match
        file = match[1]
        line_number = match[2]
        method = match[3]

        colored_file = pastel.cyan(file)
        colored_line_number = pastel.green(line_number)
        colored_method = pastel.yellow(method)

        "#{colored_file}:#{colored_line_number}:in `#{colored_method}'"
      else
        line
      end
    end
  end
end
