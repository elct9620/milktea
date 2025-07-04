# frozen_string_literal: true

module Milktea
  # Configuration class for Milktea applications
  class Config
    attr_accessor :app_dir
    attr_writer :hot_reloading, :reloader

    def initialize
      @app_dir = "app"
      @hot_reloading = nil # Will be set by lazy evaluation
      @reloader = nil # Will be set by lazy evaluation

      yield(self) if block_given?
    end

    def hot_reloading?
      @hot_reloading || (Milktea.env == :development)
    end

    def reloader
      @reloader ||= Milktea::Reloader.new
    end

    def app_path
      Milktea.root.join(@app_dir)
    end
  end
end
