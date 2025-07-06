#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "milktea"

# TextDemo model demonstrating Text component usage
class TextDemo < Milktea::Model
  child :header, flex: 1
  child :short_text, flex: 2
  child :long_text, flex: 3
  child :unicode_text, flex: 2
  child :footer, flex: 1

  def header
    HeaderText
  end

  def short_text
    ShortText
  end

  def long_text
    LongText
  end

  def unicode_text
    UnicodeText
  end

  def footer
    FooterText
  end

  def update(message)
    case message
    when Milktea::Message::KeyPress
      return [self, Milktea::Message::Quit.new] if ["q", "ctrl+c"].include?(message.key)
    end

    [self, Milktea::Message::None.new]
  end
end

# Header text component
class HeaderText < Milktea::Text
  private

  def default_state
    { content: "Milktea Text Component Demo\nPress 'q' to quit" }
  end
end

# Short text that fits within bounds
class ShortText < Milktea::Text
  private

  def default_state
    {
      content: "This is a short text that fits comfortably within the bounds. " \
               "It demonstrates basic text rendering."
    }
  end
end

# Long text that requires wrapping and truncation
class LongText < Milktea::Text
  private

  def default_state
    {
      content: "This is a much longer text that will demonstrate the wrapping " \
               "and truncation capabilities of the Text component. When text " \
               "is too long to fit within the specified width, it will " \
               "automatically wrap to the next line. If there are too many " \
               "lines to fit within the height bounds, the last visible line " \
               "will be truncated with an ellipsis. This ensures that text " \
               "always stays within its designated area and doesn't overflow " \
               "into other components. The wrapping is word-aware, so it won't " \
               "break words in the middle unless absolutely necessary."
    }
  end
end

# Unicode and emoji text
class UnicodeText < Milktea::Text
  private

  def default_state
    {
      content: "Unicode support: 你好世界 🌍🌎🌏\n" \
               "Japanese: ラドクリフ、マラソン五輪代表\n" \
               "Emoji: 🚀 🎉 🔥 ✨ 💻 📱"
    }
  end
end

# Footer text
class FooterText < Milktea::Text
  private

  def default_state
    { content: "Text components handle wrapping, truncation, and Unicode!" }
  end
end

# Create and run the program
model = TextDemo.new
program = Milktea::Program.new(model)
program.run
