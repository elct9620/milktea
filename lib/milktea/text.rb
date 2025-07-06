# frozen_string_literal: true

require "strings"
require "tty-cursor"

module Milktea
  # Text component for displaying text content with wrapping and truncation
  class Text < Container
    def view
      return "" if content.empty?

      render(truncated_lines)
    end

    private

    def render(lines)
      lines.map.with_index do |line, index|
        TTY::Cursor.move_to(bounds.x, bounds.y + index) + line
      end.join
    end

    def truncated_lines
      lines = wrap_content
      return lines unless lines.length > bounds.height

      lines.take(bounds.height)
    end

    def wrap_content
      Strings.wrap(content, bounds.width).split("\n")
    end

    def content
      state[:content] || ""
    end

    def default_state
      { content: "" }.freeze
    end
  end
end
