# frozen_string_literal: true

require "timers"

module Milktea
  # Main program class for running Milktea TUI applications
  class Program
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

      # Run the event loop
      loop do
        break unless running?

        @timers.wait
        process_commands
      end
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
