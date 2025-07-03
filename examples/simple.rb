#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "milktea"

# Simple test model
class TestModel < Milktea::Model
  def view
    "Hello from Milktea!\n"
  end

  def update(message)
    case message
    when Milktea::Message::Exit
      [self, message]
    else
      [self, Milktea::Message::None.new]
    end
  end
end

# Create and run a simple Milktea program
model = TestModel.new
program = Milktea::Program.new(model)
program.run
