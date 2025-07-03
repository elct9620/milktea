# frozen_string_literal: true

require "timers"

module Milktea
  # Main program class for running Milktea TUI applications
  class Program
    def initialize(output: $stdout)
      @output = output
      @running = false
      @timers = Timers::Group.new
    end

    def run
      @running = true

      # Simple timer that prints text once
      @timers.after(0.1) do
        @output.puts "Hello from Milktea!"
        stop
      end

      # Run the event loop
      @timers.wait while running?
    end

    def stop
      @running = false
    end

    def running?
      @running == true
    end
  end
end
