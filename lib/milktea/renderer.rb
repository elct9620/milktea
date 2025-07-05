# frozen_string_literal: true

require "tty-cursor"
require "tty-screen"

module Milktea
  # Renderer handles TUI rendering and screen management
  class Renderer
    def initialize(output = $stdout)
      @output = output
      @cursor = TTY::Cursor
      @last_screen_size = TTY::Screen.size
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

    def resize?
      current_size = TTY::Screen.size
      return false if current_size == @last_screen_size

      @last_screen_size = current_size
      true
    end
  end
end
