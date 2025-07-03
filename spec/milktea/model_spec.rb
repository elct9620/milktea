# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea::Model do
  let(:test_model_class) do
    Class.new(Milktea::Model) do
      def view
        "Count: #{state[:count]}"
      end

      def update(message)
        case message
        when :increment
          [with(count: state[:count] + 1), Milktea::Message::None.new]
        when :reset
          [with(count: 0), Milktea::Message::None.new]
        else
          [self, Milktea::Message::None.new]
        end
      end

      private

      def default_state
        { count: 0 }
      end
    end
  end

  subject(:model) { test_model_class.new }

  describe "#initialize" do
    it "merges provided state with default state" do
      custom_model = test_model_class.new(count: 5)
      expect(custom_model.state[:count]).to eq(5)
    end

    it "freezes the state" do
      expect(model.state).to be_frozen
    end

    it "uses default state when no state provided" do
      expect(model.state[:count]).to eq(0)
    end
  end

  describe "#state" do
    it "provides read access to state" do
      expect(model.state).to eq({ count: 0 })
    end
  end

  describe "#with" do
    it "creates new instance with updated state" do
      new_model = model.with(count: 5)

      expect(new_model).not_to be(model)
      expect(new_model.state[:count]).to eq(5)
      expect(model.state[:count]).to eq(0)
    end

    it "preserves existing state when merging" do
      model_with_data = test_model_class.new(count: 1, name: "test")
      new_model = model_with_data.with(count: 2)

      expect(new_model.state[:count]).to eq(2)
      expect(new_model.state[:name]).to eq("test")
    end
  end

  describe "#view" do
    it "raises NotImplementedError for base class" do
      base_model = Milktea::Model.new

      expect { base_model.view }.to raise_error(NotImplementedError)
    end

    it "can be implemented by subclasses" do
      expect(model.view).to eq("Count: 0")
    end
  end

  describe "#update" do
    it "raises NotImplementedError for base class" do
      base_model = Milktea::Model.new

      expect { base_model.update(:test) }.to raise_error(NotImplementedError)
    end

    it "returns updated model and message tuple" do
      new_model, message = model.update(:increment)

      expect(new_model.state[:count]).to eq(1)
      expect(message).to be_a(Milktea::Message::None)
    end

    it "preserves immutability" do
      original_count = model.state[:count]
      model.update(:increment)

      expect(model.state[:count]).to eq(original_count)
    end
  end
end
