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

    it { expect(model.state).to be_frozen }

    it { expect(model.state[:count]).to eq(0) }
  end

  describe "#state" do
    it { expect(model.state).to eq({ count: 0 }) }
  end

  describe "#with" do
    subject(:new_model) { model.with(count: 5) }

    it { expect(new_model).not_to be(model) }
    it { expect(new_model.state[:count]).to eq(5) }
    it { expect { model.with(count: 5) }.not_to change(model, :state) }

    context "when merging with existing state" do
      let(:model_with_data) { test_model_class.new(count: 1, name: "test") }
      subject(:merged_model) { model_with_data.with(count: 2) }

      it { expect(merged_model.state[:count]).to eq(2) }
      it { expect(merged_model.state[:name]).to eq("test") }
    end
  end

  describe "#view" do
    it "raises NotImplementedError for base class" do
      base_model = Milktea::Model.new
      expect { base_model.view }.to raise_error(NotImplementedError)
    end

    it { expect(model.view).to eq("Count: 0") }
  end

  describe "#update" do
    it "raises NotImplementedError for base class" do
      base_model = Milktea::Model.new
      expect { base_model.update(:test) }.to raise_error(NotImplementedError)
    end

    context "with increment message" do
      subject(:result) { model.update(:increment) }
      let(:new_model) { result.first }
      let(:message) { result.last }

      it { expect(new_model.state[:count]).to eq(1) }
      it { expect(message).to be_a(Milktea::Message::None) }
      it { expect { model.update(:increment) }.not_to change(model, :state) }
    end
  end
end
