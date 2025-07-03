# frozen_string_literal: true

module Milktea
  # Base model class for creating TUI components following the Elm Architecture
  class Model
    attr_reader :state

    def initialize(state = {})
      @state = default_state.merge(state).freeze
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
      self.class.new(@state.merge(new_state))
    end

    private

    # Override in subclasses to provide default state
    # @return [Hash] Default state for the model
    def default_state
      {}
    end
  end
end
