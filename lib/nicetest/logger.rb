# frozen_string_literal: true

require "logger"

module Nicetest
  class Logger
    def initialize(io)
      @pastel = Cli::PASTEL
      @io = io
    end

    def warn(message)
      log("warn ", message, color: :yellow)
    end

    def error(message)
      log("error", message, color: :red)
    end

    def info(message)
      log("info ", message, color: :cyan)
    end

    def fatal!(message)
      error(message)
      exit(1)
    end

    private

    def log(level, message, color:)
      @io.puts "#{target_level(level, color: color)} #{message}"
    end

    def target_level(level, color:)
      level = @pastel.bold.send(color, level)
      logname = @pastel.dim.italic("nicetest →")
      "#{level} #{logname}"
    end
  end
end
