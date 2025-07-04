#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "milktea"

# Counter child component
class CounterModel < Milktea::Model
  def view
    "Counter: #{state[:count]}"
  end

  def update(message)
    case message
    when Milktea::Message::KeyPress
      handle_keypress(message)
    else
      [self, Milktea::Message::None.new]
    end
  end

  private

  def default_state
    { count: 0 }
  end

  def handle_keypress(message)
    case message.value
    when "+"
      [with(count: state[:count] + 1), Milktea::Message::None.new]
    when "-"
      [with(count: state[:count] - 1), Milktea::Message::None.new]
    else
      [self, Milktea::Message::None.new]
    end
  end
end

# Status bar child component
class StatusBarModel < Milktea::Model
  def view
    "Status: #{state[:message]}"
  end

  def update(_message)
    [self, Milktea::Message::None.new]
  end

  private

  def default_state
    { message: "Ready" }
  end
end

# Dashboard parent component using nested models
class DashboardModel < Milktea::Model
  child CounterModel, ->(state) { { count: state[:count] } }
  child StatusBarModel, ->(state) { { message: state[:status_message] } }

  def view
    <<~VIEW
      === Dashboard v#{state[:app_version]} ===

      #{children_views}

      Controls:
      - '+' / '-' to change counter
      - 'r' to reset counter
      - 's' to change status
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

  def default_state
    {
      count: 0,
      status_message: "Dashboard Ready",
      app_version: "1.0"
    }
  end

  def handle_keypress(message)
    case message.value
    when "+"
      [with(count: state[:count] + 1), Milktea::Message::None.new]
    when "-"
      [with(count: state[:count] - 1), Milktea::Message::None.new]
    when "r"
      [with(count: 0, status_message: "Counter Reset!"), Milktea::Message::None.new]
    when "s"
      new_status = state[:status_message] == "Dashboard Ready" ? "Status Updated!" : "Dashboard Ready"
      [with(status_message: new_status), Milktea::Message::None.new]
    when "q"
      [self, Milktea::Message::Exit.new]
    else
      [self, Milktea::Message::None.new]
    end
  end
end

# Create and run the dashboard program
model = DashboardModel.new
program = Milktea::Program.new(model)
program.run
