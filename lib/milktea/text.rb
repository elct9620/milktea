# frozen_string_literal: true

require "strings"
require "tty-cursor"

module Milktea
  # Text component for displaying text content with wrapping and truncation
  class Text < Container
    def view
      return "" if content.empty?
      return render(truncated_lines) if state[:wrap]

      render_truncated
    end

    private

    def render(lines)
      lines.map.with_index do |line, index|
        TTY::Cursor.move_to(bounds.x, bounds.y + index) + line
      end.join
    end

    def render_truncated
      cleaned_content = content.gsub("\n", "")
      max_length = bounds.width * bounds.height
      truncated_content = Strings.truncate(cleaned_content, max_length, trailing: state[:trailing])

      TTY::Cursor.move_to(bounds.x, bounds.y) + truncated_content
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
      { content: "", wrap: false, trailing: "…" }.freeze
    end
  end
end
