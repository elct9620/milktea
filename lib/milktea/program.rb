# frozen_string_literal: true

require "timers"

module Milktea
  # Main program class for running Milktea TUI applications
  class Program
    FPS = 60
    REFRESH_INTERVAL = 1.0 / FPS

    def initialize(model, output: $stdout)
      @model = model
      @output = output
      @running = false
      @timers = Timers::Group.new
      @message_queue = Queue.new
    end

    def run
      @running = true
      setup_screen
      render
      setup_timers
      @timers.wait while running?
    ensure
      restore_screen
    end

    def stop
      @running = false
    end

    def running?
      @running == true
    end

    private

    def process_messages
      should_render = false

      until @message_queue.empty?
        message = @message_queue.pop(true) # non-blocking pop
        @model, side_effect = @model.update(message)
        execute_side_effect(side_effect)

        should_render = true unless message.is_a?(Message::None)
      end

      render if should_render
    end

    def execute_side_effect(side_effect)
      case side_effect
      when Message::None
        # Do nothing
      when Message::Exit
        stop
      when Message::Batch
        side_effect.messages.each { |msg| @message_queue << msg }
      end
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
      # Temporary timer to stop the program for testing
      @timers.after(0.1) do
        stop
      end

      # Main event loop
      @timers.now_and_every(REFRESH_INTERVAL) do
        process_messages
      end
    end
  end
end
