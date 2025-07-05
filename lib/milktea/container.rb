# frozen_string_literal: true

module Milktea
  # Container model with layout capabilities using Flexbox
  class Container < Model
    attr_reader :bounds

    class << self
      # Define a child model with optional state mapping and flex properties
      # @param klass [Class] The child model class
      # @param mapper [Proc] Lambda to map parent state to child state
      # @param flex [Integer] Flex grow factor for layout
      def child(klass, mapper = nil, flex: 1)
        @children ||= []
        @children << {
          class: klass,
          mapper: mapper || ->(_state) { {} },
          flex: flex
        }
      end
    end

    def initialize(state = {})
      @bounds = extract_bounds(state)
      # Remove bounds keys from state before passing to parent
      super(state.except(:width, :height, :x, :y))
    end

    private

    def extract_bounds(state)
      Bounds.new(
        width: state[:width] || screen_width,
        height: state[:height] || screen_height,
        x: state[:x] || 0,
        y: state[:y] || 0
      )
    end

    # Override build_children to apply flexbox layout
    def build_children(parent_state)
      return [].freeze if self.class.children.empty?

      layout_children(parent_state)
    end

    def layout_children(parent_state)
      total_flex = calculate_total_flex
      current_y = bounds.y

      self.class.children.map do |definition|
        child_height = calculate_child_height(definition[:flex], total_flex)
        child_state = build_child_state(definition, parent_state, current_y, child_height)
        current_y += child_height
        definition[:class].new(child_state)
      end.freeze
    end

    def calculate_total_flex
      self.class.children.sum { |definition| definition[:flex] }
    end

    def calculate_child_height(flex, total_flex)
      (bounds.height * flex) / total_flex
    end

    def build_child_state(definition, parent_state, pos_y, child_height)
      definition[:mapper].call(parent_state).merge(
        width: bounds.width,
        height: child_height,
        x: bounds.x,
        y: pos_y
      )
    end
  end
end
