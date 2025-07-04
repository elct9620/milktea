# frozen_string_literal: true

module Milktea
  # Configuration class for Milktea applications
  class Config
    attr_accessor :app_dir, :output
    attr_writer :hot_reloading, :runtime, :renderer

    def initialize
      @app_dir = "app"
      @output = $stdout
      @hot_reloading = nil # Will be set by lazy evaluation
      @runtime = nil # Will be set by lazy evaluation
      @renderer = nil # Will be set by lazy evaluation

      yield(self) if block_given?
    end

    def hot_reloading?
      @hot_reloading || (Milktea.env == :development)
    end

    def runtime
      @runtime ||= Runtime.new
    end

    def renderer
      @renderer ||= Renderer.new(@output)
    end

    def app_path
      Milktea.root.join(@app_dir)
    end
  end
end
