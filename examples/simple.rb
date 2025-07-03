#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "milktea"

# Simple test model
class TestModel < Milktea::Model
  def view
    "Hello from Milktea!\nPress 'q' to quit or Ctrl+C to exit\n"
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
    when "q"
      [self, Milktea::Message::Exit.new]
    else
      [self, Milktea::Message::None.new]
    end
  end
end

# Create and run a simple Milktea program
model = TestModel.new
program = Milktea::Program.new(model)
program.run
