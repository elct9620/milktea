#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "milktea"

# Counter model demonstrating state management
class CounterModel < Milktea::Model
  def initialize(state = {})
    default_state = { count: 0 }
    super(default_state.merge(state))
  end

  def view
    <<~VIEW
      Counter: #{state[:count]}

      Press:
      - '+' or 'k' to increment
      - '-' or 'j' to decrement
      - 'r' to reset
      - 'q' to quit

      Ctrl+C to exit
    VIEW
  end

  def update(message)
    case message
    when Milktea::Message::Exit
      [self, message]
    when Milktea::Message::KeyPress
      handle_keypress(message)
    else
      [self, Milktea::Message::None.new]
    end
  end

  private

  def handle_keypress(message)
    case message.value
    when "+", "k"
      [with(count: state[:count] + 1), Milktea::Message::None.new]
    when "-", "j"
      [with(count: state[:count] - 1), Milktea::Message::None.new]
    when "r"
      [with(count: 0), Milktea::Message::None.new]
    when "q"
      [self, Milktea::Message::Exit.new]
    else
      [self, Milktea::Message::None.new]
    end
  end
end

# Create and run the counter program
model = CounterModel.new
program = Milktea::Program.new(model)
program.run
