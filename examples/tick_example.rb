#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/milktea"

# Example model that uses Tick messages for animations
class TickModel < Milktea::Model
  def view
    elapsed = last_tick ? Time.now - last_tick : 0
    dots = "." * ((elapsed * 2).to_i % 4)

    <<~VIEW
      ╭─────────────────────────────────────────────────────────╮
      │                    Tick Example                         │
      ├─────────────────────────────────────────────────────────┤
      │                                                         │
      │  Loading#{dots.ljust(3)}                                  │
      │                                                         │
      │  Last tick: #{last_tick&.strftime("%H:%M:%S.%L") || "none"}         │
      │  Elapsed: #{elapsed.round(3)}s                            │
      │                                                         │
      │  Press 'q' to quit                                      │
      │                                                         │
      ╰─────────────────────────────────────────────────────────╯
    VIEW
  end

  def update(message)
    case message
    when Milktea::Message::Tick
      # Track the tick timestamp - this demonstrates that tick messages
      # provide timing information that models can use for animations
      [with(last_tick: message.timestamp), Milktea::Message::None.new]
    when Milktea::Message::KeyPress
      if message.key == "q"
        [self, Milktea::Message::Exit.new]
      else
        [self, Milktea::Message::None.new]
      end
    else
      [self, Milktea::Message::None.new]
    end
  end

  private

  def default_state
    { last_tick: nil }
  end

  def last_tick
    state[:last_tick]
  end
end

# Configure Milktea
Milktea.configure do |config|
  config.hot_reloading = false
end

# Create and run the tick demonstration
program = Milktea::Program.new(TickModel.new)
program.run
