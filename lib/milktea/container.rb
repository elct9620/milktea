# frozen_string_literal: true

module Milktea
  # Container model with layout capabilities using Flexbox
  class Container < Model
    attr_reader :bounds

    class << self
      # Define a child model with optional state mapping and flex properties
      # @param klass [Class, Symbol] The child model class or method name
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

      # Set the flex direction for the container
      # @param dir [Symbol] The direction (:column or :row)
      def direction(dir)
        @direction = dir
      end

      # Get the flex direction (defaults to :column)
      # @return [Symbol] The flex direction
      def flex_direction
        @direction || :column
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
      case self.class.flex_direction
      when :row
        layout_children_row(parent_state)
      else
        layout_children_column(parent_state)
      end
    end

    def layout_children_column(parent_state)
      total_flex = calculate_total_flex
      current_y = bounds.y

      self.class.children.map do |definition|
        child_height = calculate_child_height(definition[:flex], total_flex)
        child_state = build_child_state_column(definition, parent_state, current_y, child_height)
        current_y += child_height
        resolve_child_class(definition[:class]).new(child_state)
      end.freeze
    end

    def layout_children_row(parent_state)
      total_flex = calculate_total_flex
      current_x = bounds.x

      self.class.children.map do |definition|
        child_width = calculate_child_width(definition[:flex], total_flex)
        child_state = build_child_state_row(definition, parent_state, current_x, child_width)
        current_x += child_width
        resolve_child_class(definition[:class]).new(child_state)
      end.freeze
    end

    def calculate_total_flex
      self.class.children.sum { |definition| definition[:flex] }
    end

    def calculate_child_height(flex, total_flex)
      (bounds.height * flex) / total_flex
    end

    def calculate_child_width(flex, total_flex)
      (bounds.width * flex) / total_flex
    end

    def build_child_state_column(definition, parent_state, pos_y, child_height)
      definition[:mapper].call(parent_state).merge(
        width: bounds.width,
        height: child_height,
        x: bounds.x,
        y: pos_y
      )
    end

    def build_child_state_row(definition, parent_state, pos_x, child_width)
      definition[:mapper].call(parent_state).merge(
        width: child_width,
        height: bounds.height,
        x: pos_x,
        y: bounds.y
      )
    end

    def resolve_child_class(klass_or_symbol)
      case klass_or_symbol
      when Symbol
        # Call the method with the symbol name to get the class
        result = send(klass_or_symbol)
        raise ArgumentError, "Child must be a Class or Symbol, got #{result.class}" unless result.is_a?(Class)

        result
      when Class
        klass_or_symbol
      else
        raise ArgumentError, "Child must be a Class or Symbol, got #{klass_or_symbol.class}"
      end
    end
  end
end
