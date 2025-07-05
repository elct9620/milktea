# frozen_string_literal: true

module Milktea
  # Bounds represents the position and size of a UI element
  Bounds = Data.define(:width, :height, :x, :y) do
    def initialize(width: 0, height: 0, x: 0, y: 0) # rubocop:disable Naming/MethodParameterName
      super
    end
  end
end
