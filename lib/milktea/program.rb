# frozen_string_literal: true

require "timers"
require "tty-reader"
require "forwardable"

module Milktea
  # Main program class for running Milktea TUI applications
  class Program
    extend Forwardable
    FPS = 60
    REFRESH_INTERVAL = 1.0 / FPS

    # Delegate config accessors
    def_delegators :@config, :runtime, :renderer, :reloader

    # Delegate to runtime and renderer
    delegate %i[start stop running? tick render? enqueue] => :runtime
    delegate %i[setup_screen restore_screen render] => :renderer

    def initialize(model, config: nil)
      @model = model
      @config = config || Milktea.config
      @timers = Timers::Group.new
      @reader = TTY::Reader.new(interrupt: :error)
    end

    def run
      start
      setup_hot_reloading
      setup_screen
      render(@model)
      setup_timers
      @timers.wait while running?
    ensure
      restore_screen
    end

    private

    def setup_hot_reloading
      reloader.start
      reloader.hot_reload! if @config.hot_reloading?
    end

    def process_messages
      @model = tick(@model)
      render(@model) if render?
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
      enqueue(Message::Exit.new)
    end

    def enqueue_key_message(key)
      key_message = Message::KeyPress.new(
        key: key,
        value: key,
        ctrl: key == "\u0003", # Ctrl+C
        alt: false,
        shift: false
      )
      enqueue(key_message)
    end
  end
end
