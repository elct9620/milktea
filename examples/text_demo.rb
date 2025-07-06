#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "milktea"

# TextDemo model demonstrating Text component usage
class TextDemo < Milktea::Container
  direction :column
  child :header, flex: 1
  child :short_text, flex: 2
  child :long_text, flex: 3
  child :truncated_text, flex: 2
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

  def truncated_text
    TruncatedText
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
      return [self, Milktea::Message::Exit.new] if ["q", "ctrl+c"].include?(message.key)
    When Milktea::Message::Resize
      return [with, Milktea::Message::None.new]
    end

    [self, Milktea::Message::None.new]
  end
end

# Header text component
class HeaderText < Milktea::Text
  private

  def default_state
    {
      content: "Milktea Text Component Demo\nPress 'q' to quit",
      wrap: true
    }
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
               "break words in the middle unless absolutely necessary.",
      wrap: true
    }
  end
end

# Truncated text demonstrating the new truncation mode
class TruncatedText < Milktea::Text
  private

  def default_state
    {
      content: "This demonstrates the new truncation mode (wrap: false). " \
               "Newlines are removed and text is truncated to fit within " \
               "width * height characters. Custom trailing can be set.",
      trailing: "..."
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
