# frozen_string_literal: true

module Milktea
  # Message definitions for events in the Milktea framework
  module Message
    # No operation message
    None = Data.define

    # Message to exit the program
    Exit = Data.define

    # Timer tick message
    Tick = Data.define

    # Batch multiple messages
    Batch = Data.define(:messages) do
      def initialize(messages: [])
        super
      end
    end
  end
end
