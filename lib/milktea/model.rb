# frozen_string_literal: true

module Milktea
  # Base model class for creating TUI components following the Elm Architecture
  class Model
    attr_reader :state, :children

    class << self
      # Define a child model with optional state mapping
      # @param klass [Class] The child model class
      # @param mapper [Proc] Lambda to map parent state to child state
      def child(klass, mapper = nil)
        @children ||= []
        @children << {
          class: klass,
          mapper: mapper || ->(_state) { {} }
        }
      end

      # Get all child definitions for this model
      # @return [Array<Hash>] Array of child definitions
      def children
        @children ||= []
      end
    end

    def initialize(state = {})
      @state = default_state.merge(state).freeze
      @children = build_children(@state)
    end

    # Render the model to a string representation
    # @return [String] The rendered output
    def view
      raise NotImplementedError, "#{self.class} must implement #view"
    end

    # Update the model based on a message
    # @param message [Object] The message to process
    # @return [Array(Model, Message)] New model and side effect message
    def update(message)
      raise NotImplementedError, "#{self.class} must implement #update"
    end

    # Create a new instance with updated state
    # @param new_state [Hash] State updates to merge
    # @return [Model] New model instance with updated state
    def with(new_state = {})
      merged_state = @state.merge(new_state)
      self.class.new(merged_state)
    end

    # Combine all children views into a single string
    # @return [String] Combined views of all children
    def children_views
      @children.map(&:view).join("\n")
    end

    private

    # Build child model instances based on class definitions
    # @param parent_state [Hash] The parent model's state
    # @return [Array<Model>] Array of child model instances
    def build_children(parent_state)
      self.class.children.map do |definition|
        klass = definition[:class]
        state = definition[:mapper].call(parent_state)
        klass.new(state)
      end.freeze
    end

    # Override in subclasses to provide default state
    # @return [Hash] Default state for the model
    def default_state
      {}
    end
  end
end
