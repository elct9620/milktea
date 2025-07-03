# frozen_string_literal: true

require "timers"

module Milktea
  # Main program class for running Milktea TUI applications
  class Program
    FPS = 60
    REFRESH_INTERVAL = 1.0 / FPS

    def initialize(output: $stdout)
      @output = output
      @running = false
      @timers = Timers::Group.new
      @message_queue = Queue.new
    end

    def run
      @running = true

      # Simple timer that prints text once
      @timers.after(0.1) do
        @output.puts "Hello from Milktea!"
        @message_queue << Message::Exit.new
      end

      # Main event loop
      @timers.now_and_every(REFRESH_INTERVAL) do
        process_messages
      end

      # Continue processing timers until stopped
      @timers.wait while running?
    end

    def stop
      @running = false
    end

    def running?
      @running == true
    end

    private

    def process_messages
      until @message_queue.empty?
        message = @message_queue.pop(true) # non-blocking pop
        execute_message(message)
      end
    end

    def execute_message(message)
      case message
      when Message::None
        # Do nothing
      when Message::Exit
        stop
      when Message::Batch
        message.messages.each { |msg| @message_queue << msg }
      end
    end
  end
end
