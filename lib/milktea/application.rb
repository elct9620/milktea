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
        return @root_model_name if model_name.nil?

        @root_model_name = model_name
      end

      def root_model_class
        return unless @root_model_name

        Kernel.const_get(@root_model_name)
      end

      def boot
        return new.run if @root_model_name

        raise Error, "No root model defined. Use 'root \"ModelName\"' in your Application class."
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
      unless self.class.root_model_class
        raise Error,
              "No root model defined. Use 'root \"ModelName\"' in your Application class."
      end

      @program = Program.new(self.class.root_model_class.new, config: config)
    end
  end
end
