# frozen_string_literal: true

require "zeitwerk"

module Milktea
  # Auto loading and hot reloading implementation for Milktea applications
  class Loader
    def initialize(app_dir, runtime)
      @app_dir = app_dir
      @runtime = runtime
      @loader = nil
      @listener = nil
    end

    def start
      setup_loader
    end

    def hot_reload
      gem "listen"
      require "listen"

      @listener = Listen.to(@app_dir, only: /\.rb$/) do |modified, added, removed|
        reload if modified.any? || added.any? || removed.any?
      end
      @listener.start
    rescue Gem::LoadError
      # Listen gem not available, skip file watching
    end

    def reload
      return unless @loader

      @loader.reload
      @runtime.enqueue(Message::Reload.new)
    end

    private

    def setup_loader
      @loader = Zeitwerk::Loader.new
      @loader.push_dir(@app_dir)
      @loader.enable_reloading
      @loader.setup
    end
  end
end
