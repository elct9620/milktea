# frozen_string_literal: true

require "zeitwerk"

module Milktea
  # Auto loading and hot reloading implementation for Milktea applications
  class Loader
    def initialize(config = nil)
      @config = config || Milktea.config
      @autoload_paths = @config.autoload_paths
      @runtime = @config.runtime
      @loader = nil
      @listeners = []
    end

    def setup
      @loader = Zeitwerk::Loader.new
      @autoload_paths.each { |path| @loader.push_dir(path) }
      @loader.enable_reloading
      @loader.setup
    end

    def hot_reload
      gem "listen"
      require "listen"

      @listeners = @autoload_paths.map do |path|
        Listen.to(path, only: /\.rb$/) do |modified, added, removed|
          reload if modified.any? || added.any? || removed.any?
        end
      end

      @listeners.each(&:start)
    rescue Gem::LoadError
      # Listen gem not available, skip file watching
    end

    def reload
      return unless @loader

      @loader.reload
      @runtime.enqueue(Message::Reload.new)
    end
  end
end
