# frozen_string_literal: true

# Status Model - Child Component for Hot Reload Demo
#
# This demonstrates how child models are also reloaded automatically.
# Try modifying this component while the demo is running:
# 1. Change the status display format
# 2. Add additional information
# 3. Modify the styling

class StatusModel < Milktea::Model
  def view
    <<~VIEW
      Status: #{state[:message]}
      Last Updated: #{state[:timestamp]}

      [Tip: Try editing status_model.rb to change this display!]
    VIEW
  end

  def update(_message)
    # Status model is read-only, managed by parent
    [self, Milktea::Message::None.new]
  end

  private

  def default_state
    {
      message: "Default status",
      timestamp: Time.now.strftime("%H:%M:%S")
    }
  end
end
