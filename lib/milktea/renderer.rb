# frozen_string_literal: true

require "tty-cursor"

module Milktea
  # Renderer handles TUI rendering and screen management
  class Renderer
    def initialize(output = $stdout)
      @output = output
      @cursor = TTY::Cursor
    end

    def render(model)
      @output.print @cursor.clear_screen
      @output.print @cursor.move_to(0, 0)
      content = model.view
      @output.print content
      @output.flush
    end

    def setup_screen
      @output.print @cursor.hide
      @output.print @cursor.clear_screen
      @output.print @cursor.move_to(0, 0)
      @output.flush
    end

    def restore_screen
      @output.print @cursor.clear_screen
      @output.print @cursor.show
      @output.flush
    end
  end
end
