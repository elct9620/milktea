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
      @command_queue = Queue.new
    end

    def run
      @running = true

      # Simple timer that prints text once
      @timers.after(0.1) do
        @output.puts "Hello from Milktea!"
        @command_queue << Command::Exit.new
      end

      # Main event loop
      @timers.now_and_every(REFRESH_INTERVAL) do
        process_commands
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

    def process_commands
      until @command_queue.empty?
        command = @command_queue.pop(true) # non-blocking pop
        execute_command(command)
      end
    end

    def execute_command(command)
      case command
      when Command::None
        # Do nothing
      when Command::Exit
        stop
      when Command::Batch
        command.commands.each { |cmd| @command_queue << cmd }
      end
    end
  end
end
