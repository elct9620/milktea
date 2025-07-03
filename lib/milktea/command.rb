# frozen_string_literal: true

module Milktea
  # Command definitions for side effects in the Milktea framework
  module Command
    # No operation command
    None = Data.define

    # Command to exit the program
    Exit = Data.define

    # Timer tick command
    Tick = Data.define

    # Batch multiple commands
    Batch = Data.define(:commands) do
      def initialize(commands: [])
        super
      end
    end
  end
end
