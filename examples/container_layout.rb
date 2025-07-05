#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "milktea"
require "tty-box"

# Box model that renders a tty-box with content
class BoxModel < Milktea::Container
  def view
    TTY::Box.frame(
      top: bounds.y,
      left: bounds.x,
      width: bounds.width,
      height: bounds.height,
      title: { top_left: " #{state[:title]} " },
      border: :light,
      padding: 1,
      align: :center
    ) do
      content_lines.join("\n")
    end
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
    { title: "Box", content: "Content", value: 0 }
  end

  def content_lines
    lines = []
    lines << state[:content] if state[:content]
    lines << "Value: #{state[:value]}" if state.key?(:value)
    lines << ""
    lines << bounds_info
    lines
  end

  def bounds_info
    "#{bounds.width}×#{bounds.height} @(#{bounds.x},#{bounds.y})"
  end

  def handle_keypress(message)
    case message.value
    when "+"
      [with(value: state[:value] + 1), Milktea::Message::None.new]
    when "-"
      [with(value: state[:value] - 1), Milktea::Message::None.new]
    else
      [self, Milktea::Message::None.new]
    end
  end
end

# Column layout container
class ColumnLayoutModel < Milktea::Container
  direction :column
  child BoxModel, ->(state) { { title: "Header", content: "Top Section", value: state[:header_value] } }, flex: 1
  child BoxModel, ->(state) { { title: "Content", content: "Main Area", value: state[:content_value] } }, flex: 3
  child BoxModel, ->(state) { { title: "Footer", content: "Bottom Status", value: state[:footer_value] } }, flex: 1

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
    { header_value: 1, content_value: 10, footer_value: 5 }
  end

  def handle_keypress(message)
    case message.value
    when "+"
      [with(
        header_value: state[:header_value] + 1,
        content_value: state[:content_value] + 1,
        footer_value: state[:footer_value] + 1
      ), Milktea::Message::None.new]
    when "-"
      [with(
        header_value: [state[:header_value] - 1, 0].max,
        content_value: [state[:content_value] - 1, 0].max,
        footer_value: [state[:footer_value] - 1, 0].max
      ), Milktea::Message::None.new]
    when "q"
      [self, Milktea::Message::Exit.new]
    else
      [self, Milktea::Message::None.new]
    end
  end
end

# Row layout container
class RowLayoutModel < Milktea::Container
  direction :row
  child BoxModel, ->(state) { { title: "Left", content: "Sidebar", value: state[:left_value] } }, flex: 1
  child BoxModel, ->(state) { { title: "Center", content: "Main Content", value: state[:center_value] } }, flex: 2
  child BoxModel, ->(state) { { title: "Right", content: "Info Panel", value: state[:right_value] } }, flex: 1

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
    { left_value: 3, center_value: 7, right_value: 2 }
  end

  def handle_keypress(message)
    case message.value
    when "+"
      [with(
        left_value: state[:left_value] + 1,
        center_value: state[:center_value] + 1,
        right_value: state[:right_value] + 1
      ), Milktea::Message::None.new]
    when "-"
      [with(
        left_value: [state[:left_value] - 1, 0].max,
        center_value: [state[:center_value] - 1, 0].max,
        right_value: [state[:right_value] - 1, 0].max
      ), Milktea::Message::None.new]
    when "q"
      [self, Milktea::Message::Exit.new]
    else
      [self, Milktea::Message::None.new]
    end
  end
end

# Status bar model
class StatusBar < Milktea::Model
  def view
    layout_type = state[:show_column] ? "Column" : "Row"
    TTY::Box.frame(
      top: bounds.y,
      left: bounds.x,
      width: bounds.width,
      height: bounds.height,
      title: { top_left: " Layout Demo " },
      border: :light,
      align: :center
    ) do
      "Current: #{layout_type} Layout | 't' toggle | '+/-' change values | 'q' quit"
    end
  end

  def update(_message)
    [self, Milktea::Message::None.new]
  end

  private

  def bounds
    @bounds ||= Milktea::Bounds.new(
      width: state[:width] || screen_width,
      height: state[:height] || screen_height,
      x: state[:x] || 0,
      y: state[:y] || 0
    )
  end
end



# Main application that toggles between layouts
class LayoutDemoModel < Milktea::Container
  direction :column
  child :status_bar, flex: 1
  child :dynamic_layout, lambda { |state|
    state.slice(:header_value, :content_value, :footer_value, :left_value, :center_value, :right_value)
  }, flex: 5

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
    {
      show_column: true,
      header_value: 1,
      content_value: 10,
      footer_value: 5,
      left_value: 3,
      center_value: 7,
      right_value: 2
    }
  end

  def status_bar
    StatusBar
  end

  def dynamic_layout
    state[:show_column] ? ColumnLayoutModel : RowLayoutModel
  end

  def handle_keypress(message)
    case message.value
    when "t"
      [with(show_column: !state[:show_column]), Milktea::Message::None.new]
    when "+"
      increment_values
    when "-"
      decrement_values
    when "q"
      [self, Milktea::Message::Exit.new]
    else
      [self, Milktea::Message::None.new]
    end
  end

  def increment_values
    [with(
      header_value: state[:header_value] + 1,
      content_value: state[:content_value] + 1,
      footer_value: state[:footer_value] + 1,
      left_value: state[:left_value] + 1,
      center_value: state[:center_value] + 1,
      right_value: state[:right_value] + 1
    ), Milktea::Message::None.new]
  end

  def decrement_values
    [with(
      header_value: [state[:header_value] - 1, 0].max,
      content_value: [state[:content_value] - 1, 0].max,
      footer_value: [state[:footer_value] - 1, 0].max,
      left_value: [state[:left_value] - 1, 0].max,
      center_value: [state[:center_value] - 1, 0].max,
      right_value: [state[:right_value] - 1, 0].max
    ), Milktea::Message::None.new]
  end
end

# Create and run the layout demo
puts "Container Layout Demo"
puts "Press 't' to toggle between column and row layouts"
puts "Use +/- to change values, 'q' to quit"
puts "Press any key to start..."
$stdin.gets

model = LayoutDemoModel.new
program = Milktea::Program.new(model)
program.run
