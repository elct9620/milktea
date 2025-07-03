# frozen_string_literal: true

require "timers"

module Milktea
  # Main program class for running Milktea TUI applications
  class Program
    FPS = 60
    REFRESH_INTERVAL = 1.0 / FPS

    def initialize(model, runtime: nil, renderer: nil, output: $stdout)
      @model = model
      @runtime = runtime || Runtime.new
      @renderer = renderer || Renderer.new(output)
      @timers = Timers::Group.new
    end

    def run
      @runtime.start
      @renderer.setup_screen
      @renderer.render(@model)
      setup_timers
      @timers.wait while running?
    ensure
      @renderer.restore_screen
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
      @renderer.render(@model) if @runtime.render?
    end

    def setup_timers
      # Main event loop
      @timers.now_and_every(REFRESH_INTERVAL) do
        process_messages
      end
    end
  end
end
