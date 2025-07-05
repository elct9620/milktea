# frozen_string_literal: true

require "zeitwerk"

module Milktea
  # Application class provides a high-level interface for creating Milktea applications
  # It encapsulates the Loader and Program setup, making it easier to create TUI applications
  class Application
    class << self
      def inherited(subclass)
        super

        Milktea.app = subclass
      end

      def root(model_name = nil)
        if model_name
          @root_model_name = model_name
        else
          @root_model_name
        end
      end

      def root_model_class
        return unless @root_model_name

        Object.const_get(@root_model_name)
      end
    end

    attr_reader :config, :loader, :program

    def initialize(config: nil)
      @config = config || Milktea.config
      setup_loader
      setup_program
    end

    def run
      loader.hot_reload if config.hot_reloading?
      program.run
    end

    private

    def setup_loader
      @loader = Loader.new(config)
      loader.setup
    end

    def setup_program
      root_model = self.class.root_model_class&.new
      raise Error, "No root model defined. Use 'root \"ModelName\"' in your Application class." unless root_model

      @program = Program.new(root_model, config: config)
    end
  end
end
