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

    # Keyboard event message
    KeyPress = Data.define(:key, :value, :ctrl, :alt, :shift) do
      def initialize(key:, value:, ctrl: false, alt: false, shift: false)
        super
      end
    end

    # Batch multiple messages
    Batch = Data.define(:messages) do
      def initialize(messages: [])
        super
      end
    end

    # Hot reload message
    Reload = Data.define

    # Terminal resize message
    Resize = Data.define(:width, :height) do
      def initialize(width: TTY::Screen.width, height: TTY::Screen.height)
        super
      end
    end
  end
end
