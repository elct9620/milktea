# frozen_string_literal: true

require "zeitwerk"
require "pathname"

loader = Zeitwerk::Loader.for_gem
loader.setup

# The Milktea TUI framework for Ruby
module Milktea
  class Error < StandardError; end

  CONFIG_MUTEX = Mutex.new

  class << self
    def root
      @root ||= find_root
    end

    def env
      (ENV.fetch("MILKTEA_ENV", nil) || ENV.fetch("APP_ENV", "production")).to_sym
    end

    def config
      CONFIG_MUTEX.synchronize do
        @config ||= Config.new
      end
    end

    def configure(&block)
      CONFIG_MUTEX.synchronize do
        @config = if block_given?
                    Config.new(&block)
                  else
                    Config.new
                  end
      end
    end

    private

    def find_root
      return Pathname.new(Bundler.root) if defined?(Bundler) && Bundler.respond_to?(:root)

      # Find root by looking for common project files
      current_dir = Pathname.new(Dir.pwd)
      while current_dir.parent != current_dir
        return current_dir if project_root?(current_dir)

        current_dir = current_dir.parent
      end

      # Default to current directory if no project root found
      Pathname.new(Dir.pwd)
    end

    def project_root?(dir)
      %w[Gemfile Gemfile.lock .git].any? { |file| dir.join(file).exist? }
    end
  end
end
