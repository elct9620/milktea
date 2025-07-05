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
    it { expect(model.state).to be_frozen }

    it { expect(model.state[:count]).to eq(0) }

    context "when merging provided state with default state" do
      subject(:custom_model) { test_model_class.new(count: 5) }

      it { expect(custom_model.state[:count]).to eq(5) }
    end
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
    context "when called on base class" do
      subject(:base_model) { Milktea::Model.new }

      it { expect { base_model.view }.to raise_error(NotImplementedError) }
    end

    it { expect(model.view).to eq("Count: 0") }
  end

  describe "#update" do
    context "when called on base class" do
      subject(:base_model) { Milktea::Model.new }

      it { expect { base_model.update(:test) }.to raise_error(NotImplementedError) }
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

  describe "nested models" do
    let(:child_model_class) do
      Class.new(Milktea::Model) do
        def view
          "Child Count: #{state[:count]}"
        end

        def update(_message)
          [self, Milktea::Message::None.new]
        end

        private

        def default_state
          { count: 0 }
        end
      end
    end

    let(:status_model_class) do
      Class.new(Milktea::Model) do
        def view
          "Status: #{state[:message]}"
        end

        def update(_message)
          [self, Milktea::Message::None.new]
        end

        private

        def default_state
          { message: "Ready" }
        end
      end
    end

    let(:parent_model_class) do
      child_class = child_model_class
      status_class = status_model_class

      Class.new(Milktea::Model) do
        child child_class, ->(state) { { count: state[:count] } }
        child status_class, ->(state) { { message: state[:status_message] } }

        def view
          "Parent: #{children_views}"
        end

        def update(_message)
          [self, Milktea::Message::None.new]
        end

        private

        def default_state
          { count: 5, status_message: "Active" }
        end
      end
    end

    subject(:parent_model) { parent_model_class.new }

    describe ".child" do
      it { expect(parent_model_class.children.size).to eq(2) }

      context "when examining first child definition" do
        subject(:definition) { parent_model_class.children.first }

        it { expect(definition[:class]).to eq(child_model_class) }
        it { expect(definition[:mapper]).to be_a(Proc) }
      end
    end

    describe "#children" do
      it { expect(parent_model.children.size).to eq(2) }
      it { expect(parent_model.children).to be_frozen }

      context "when checking child state mapping" do
        subject(:child_count_model) { parent_model.children[0] }

        it { expect(child_count_model.state[:count]).to eq(5) }
      end

      context "when checking status child" do
        subject(:status_model) { parent_model.children[1] }

        it { expect(status_model.state[:message]).to eq("Active") }
      end
    end

    describe "#children_views" do
      subject(:combined_views) { parent_model.children_views }

      it { expect(combined_views).to eq("Child Count: 5Status: Active") }
    end

    describe "#with" do
      subject(:updated_model) { parent_model.with(count: 10, status_message: "Updated") }

      it { expect(updated_model).not_to be(parent_model) }

      context "when checking updated child states" do
        subject(:child_count_model) { updated_model.children[0] }

        it { expect(child_count_model.state[:count]).to eq(10) }
      end

      context "when checking updated status child" do
        subject(:status_model) { updated_model.children[1] }

        it { expect(status_model.state[:message]).to eq("Updated") }
      end

      context "when comparing child instances" do
        let(:original_children) { parent_model.children }
        let(:new_children) { updated_model.children }

        it { expect(new_children[0]).not_to be(original_children[0]) }
        it { expect(new_children[1]).not_to be(original_children[1]) }
      end
    end

    describe "#view" do
      subject(:parent_view) { parent_model.view }

      it { expect(parent_view).to include("Child Count: 5") }
      it { expect(parent_view).to include("Status: Active") }
    end

    context "with isolated child state" do
      let(:isolated_parent_class) do
        child_class = child_model_class

        Class.new(Milktea::Model) do
          child child_class # No state mapper = isolated state

          def view
            children_views
          end

          def update(_message)
            [self, Milktea::Message::None.new]
          end

          private

          def default_state
            { app_state: "running" }
          end
        end
      end

      subject(:isolated_parent) { isolated_parent_class.new }

      context "when no state mapper provided" do
        subject(:child) { isolated_parent.children[0] }

        it { expect(child.state[:count]).to eq(0) }
      end

      context "when parent state changes" do
        subject(:updated_parent) { isolated_parent.with(app_state: "stopped") }

        it { expect(updated_parent.children[0].state[:count]).to eq(0) }
      end
    end
  end

  describe "dynamic child resolution" do
    let(:dynamic_model_class) do
      Class.new(described_class) do
        child :dynamic_child
        child Class.new(Milktea::Model)

        def view
          "Dynamic Parent"
        end

        def update(_message)
          [self, Milktea::Message::None.new]
        end

        def dynamic_child
          state[:use_special] ? SpecialChildModel : RegularChildModel
        end
      end
    end

    let(:special_child_model) do
      Class.new(described_class) do
        def view
          "Special"
        end

        def update(_message)
          [self, Milktea::Message::None.new]
        end
      end
    end

    let(:regular_child_model) do
      Class.new(described_class) do
        def view
          "Regular"
        end

        def update(_message)
          [self, Milktea::Message::None.new]
        end
      end
    end

    before do
      stub_const("SpecialChildModel", special_child_model)
      stub_const("RegularChildModel", regular_child_model)
    end

    context "when using regular child" do
      subject(:model) { dynamic_model_class.new(use_special: false) }

      it { expect(model.children.first).to be_a(RegularChildModel) }
    end

    context "when using special child" do
      subject(:model) { dynamic_model_class.new(use_special: true) }

      it { expect(model.children.first).to be_a(SpecialChildModel) }
    end

    context "when invalid child type" do
      let(:invalid_model_class) do
        Class.new(described_class) do
          child :invalid_child

          def view
            "Invalid Parent"
          end

          def update(_message)
            [self, Milktea::Message::None.new]
          end

          def invalid_child
            "not a class"
          end
        end
      end

      subject(:model) { invalid_model_class.new }

      it { expect { model.children }.to raise_error(ArgumentError, /Child must be a Model class/) }
    end

    context "when method not found" do
      let(:missing_method_model_class) do
        Class.new(described_class) do
          child :missing_method

          def view
            "Missing Method Parent"
          end

          def update(_message)
            [self, Milktea::Message::None.new]
          end
        end
      end

      subject(:model) { missing_method_model_class.new }

      it { expect { model.children }.to raise_error(ArgumentError, /Method missing_method not found/) }
    end
  end

  describe "screen methods" do
    before do
      allow(TTY::Screen).to receive(:width).and_return(80)
      allow(TTY::Screen).to receive(:height).and_return(24)
      allow(TTY::Screen).to receive(:size).and_return([80, 24])
    end

    describe "#screen_width" do
      it { expect(model.screen_width).to eq(80) }
    end

    describe "#screen_height" do
      it { expect(model.screen_height).to eq(24) }
    end

    describe "#screen_size" do
      it { expect(model.screen_size).to eq([80, 24]) }
    end
  end
end
