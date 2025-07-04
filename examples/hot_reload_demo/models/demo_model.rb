# frozen_string_literal: true

# Hot Reload Demo Model
#
# This model demonstrates hot reloading capabilities.
# While the program is running, try modifying this file:
# 1. Change the welcome message below
# 2. Modify the counter increment value
# 3. Add new key bindings
# 4. Change the view layout
#
# The changes should be reflected immediately in the running program!

class DemoModel < Milktea::Model
  child StatusModel, ->(state) { { message: state[:status], timestamp: state[:last_update] } }

  def view
    <<~VIEW
      === Hot Reload Demo ===

      Welcome! This demo shows hot reloading in action.

      Counter: #{state[:count]} (try changing the increment value in demo_model.rb!)

      #{children_views}

      Instructions:
      - '+' or 'k' to increment counter
      - '-' or 'j' to decrement counter#{"  "}
      - 'r' to reset counter
      - 'm' to change status message
      - 'q' to quit

      Try editing this file while the program runs!
      (Change the welcome message or add new features)

      Ctrl+C to exit
    VIEW
  end

  def update(message)
    case message
    when Milktea::Message::Exit
      [self, message]
    when Milktea::Message::KeyPress
      handle_keypress(message)
    when Milktea::Message::Reload
      # Hot reload detected - model will be automatically rebuilt
      [self, Milktea::Message::None.new]
    else
      [self, Milktea::Message::None.new]
    end
  end

  private

  def default_state
    {
      count: 0,
      status: "Ready for hot reloading!",
      last_update: Time.now.strftime("%H:%M:%S")
    }
  end

  def handle_keypress(message)
    case message.value
    when "+", "k"
      # Try changing this increment value from 1 to 5 while running!
      new_count = state[:count] + 1
      [with(count: new_count, last_update: Time.now.strftime("%H:%M:%S")), Milktea::Message::None.new]
    when "-", "j"
      new_count = state[:count] - 1
      [with(count: new_count, last_update: Time.now.strftime("%H:%M:%S")), Milktea::Message::None.new]
    when "r"
      [with(count: 0, status: "Counter reset!", last_update: Time.now.strftime("%H:%M:%S")), Milktea::Message::None.new]
    when "m"
      messages = [
        "Hot reloading is awesome!",
        "Change this file and see it update!",
        "Ruby + TUI = Great experience",
        "Milktea framework rocks!"
      ]
      new_status = messages.sample
      [with(status: new_status, last_update: Time.now.strftime("%H:%M:%S")), Milktea::Message::None.new]
    when "q"
      [self, Milktea::Message::Exit.new]
    else
      [self, Milktea::Message::None.new]
    end
  end
end
