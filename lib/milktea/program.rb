# frozen_string_literal: true

require "timers"
require "tty-reader"

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
      @reader = TTY::Reader.new(interrupt: :error)
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
        read_keyboard_input
        process_messages
      end
    end

    def read_keyboard_input
      key = @reader.read_keypress(nonblock: true)
      return if key.nil?

      enqueue_key_message(key)
    rescue TTY::Reader::InputInterrupt
      @runtime.enqueue(Message::Exit.new)
    end

    def enqueue_key_message(key)
      key_message = Message::KeyPress.new(
        key: key,
        value: key,
        ctrl: key == "\u0003", # Ctrl+C
        alt: false,
        shift: false
      )
      @runtime.enqueue(key_message)
    end
  end
end
