# frozen_string_literal: true

require "timers"

module Milktea
  # Main program class for running Milktea TUI applications
  class Program
    FPS = 60
    REFRESH_INTERVAL = 1.0 / FPS

    def initialize(model, runtime: nil, output: $stdout)
      @model = model
      @runtime = runtime || Runtime.new
      @output = output
      @timers = Timers::Group.new
    end

    def run
      @runtime.start
      setup_screen
      render
      setup_timers
      @timers.wait while running?
    ensure
      restore_screen
    end

    def stop
      @runtime.stop
    end

    def running?
      @runtime.running?
    end

    private

    def process_messages
      @model = @runtime.tick(@model)
      render if @runtime.render?
    end

    def render
      content = @model.view
      @output.print content
      @output.flush
    end

    def setup_screen
      # Terminal setup can be added here
    end

    def restore_screen
      # Terminal cleanup can be added here
    end

    def setup_timers
      # Main event loop
      @timers.now_and_every(REFRESH_INTERVAL) do
        process_messages
      end
    end
  end
end
