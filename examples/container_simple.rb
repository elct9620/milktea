#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "milktea"
require "tty-box"

# Simple box component
class SimpleBox < Milktea::Container
  def view
    TTY::Box.frame(
      top: bounds.y,
      left: bounds.x,
      width: bounds.width,
      height: bounds.height,
      title: { top_left: " #{state[:title]} " },
      border: :light,
      padding: 1
    ) do
      "#{state[:content]}\n#{bounds.width}×#{bounds.height}"
    end
  end

  def update(_message)
    [self, Milktea::Message::None.new]
  end

  private

  def default_state
    { title: "Box", content: "Hello" }
  end
end

# Row layout example
class RowDemo < Milktea::Container
  direction :row
  child SimpleBox, ->(_state) { { title: "Left", content: "Panel 1" } }, flex: 1
  child SimpleBox, ->(_state) { { title: "Center", content: "Main Area" } }, flex: 2
  child SimpleBox, ->(_state) { { title: "Right", content: "Panel 3" } }, flex: 1

  def view
    children_views
  end

  def update(message)
    case message
    when Milktea::Message::KeyPress
      if message.value == "q"
        [self, Milktea::Message::Exit.new]
      else
        [self, Milktea::Message::None.new]
      end
    else
      [self, Milktea::Message::None.new]
    end
  end
end

# Test the layout
puts "Simple Container Row Layout Test"
puts "Press 'q' to quit, any other key to continue..."

model = RowDemo.new(width: 60, height: 15)
program = Milktea::Program.new(model)
program.run
