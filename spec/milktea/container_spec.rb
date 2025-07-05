# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea::Container do
  before do
    # Mock screen dimensions for consistent testing
    allow_any_instance_of(described_class).to receive(:screen_width).and_return(80)
    allow_any_instance_of(described_class).to receive(:screen_height).and_return(24)
  end
  let(:test_model_class) do
    Class.new(described_class) do
      def view
        "Model: #{state[:name]} (#{bounds.width}x#{bounds.height})"
      end

      def update(_message)
        [self, Milktea::Message::None.new]
      end

      private

      def default_state
        { name: "test" }
      end
    end
  end

  let(:container_class) do
    child_class = test_model_class

    Class.new(described_class) do
      child child_class, ->(state) { { name: state[:title] } }, flex: 1
      child child_class, ->(state) { { name: state[:footer] } }, flex: 2

      def view
        "Container: #{children_views}"
      end

      def update(_message)
        [self, Milktea::Message::None.new]
      end

      private

      def default_state
        { title: "header", footer: "footer" }
      end
    end
  end

  describe "#initialize" do
    context "with bounds in state" do
      subject(:container) { container_class.new(width: 100, height: 80, x: 10, y: 20) }

      it { expect(container.bounds.width).to eq(100) }
      it { expect(container.bounds.height).to eq(80) }
      it { expect(container.bounds.x).to eq(10) }
      it { expect(container.bounds.y).to eq(20) }
    end

    context "with default bounds" do
      subject(:container) { container_class.new }

      it { expect(container.bounds.width).to eq(80) }
      it { expect(container.bounds.height).to eq(24) }
      it { expect(container.bounds.x).to eq(0) }
      it { expect(container.bounds.y).to eq(0) }
    end

    context "with explicit dimension override" do
      subject(:container) { container_class.new(width: 100, height: 50) }

      it { expect(container.bounds.width).to eq(100) }
      it { expect(container.bounds.height).to eq(50) }
      it { expect(container.bounds.x).to eq(0) }
      it { expect(container.bounds.y).to eq(0) }
    end

    context "when bounds are extracted from state" do
      subject(:container) { container_class.new(width: 100, height: 80, title: "test") }

      it { expect(container.state[:title]).to eq("test") }
      it { expect(container.state).not_to have_key(:width) }
      it { expect(container.state).not_to have_key(:height) }
    end
  end

  describe ".child" do
    it { expect(container_class.children.size).to eq(2) }

    context "when examining first child definition" do
      subject(:definition) { container_class.children.first }

      it { expect(definition[:class]).to eq(test_model_class) }
      it { expect(definition[:mapper]).to be_a(Proc) }
      it { expect(definition[:flex]).to eq(1) }
    end

    context "when examining second child definition" do
      subject(:definition) { container_class.children.last }

      it { expect(definition[:flex]).to eq(2) }
    end
  end

  describe "#children" do
    subject(:container) { container_class.new(width: 100, height: 90, title: "header", footer: "footer") }

    it { expect(container.children.size).to eq(2) }

    context "when checking first child layout" do
      subject(:first_child) { container.children[0] }

      it { expect(first_child.bounds.width).to eq(100) }
      it { expect(first_child.bounds.height).to eq(30) }
      it { expect(first_child.bounds.x).to eq(0) }
      it { expect(first_child.bounds.y).to eq(0) }
    end

    context "when checking second child layout" do
      subject(:second_child) { container.children[1] }

      it { expect(second_child.bounds.width).to eq(100) }
      it { expect(second_child.bounds.height).to eq(60) }
      it { expect(second_child.bounds.x).to eq(0) }
      it { expect(second_child.bounds.y).to eq(30) }
    end

    context "when checking child state mapping" do
      subject(:first_child) { container.children[0] }

      it { expect(first_child.state[:name]).to eq("header") }
    end
  end

  describe "flexbox layout calculation" do
    let(:three_column_class) do
      child_class = test_model_class

      Class.new(described_class) do
        child child_class, ->(_state) { { name: "child" } }, flex: 1
        child child_class, ->(_state) { { name: "child" } }, flex: 2
        child child_class, ->(_state) { { name: "child" } }, flex: 1

        def view
          children_views
        end

        def update(_message)
          [self, Milktea::Message::None.new]
        end
      end
    end

    subject(:container) { three_column_class.new(width: 100, height: 120) }

    context "when checking equal flex distribution" do
      subject(:first_child) { container.children[0] }

      it { expect(first_child.bounds.height).to eq(30) }
    end

    context "when checking double flex distribution" do
      subject(:second_child) { container.children[1] }

      it { expect(second_child.bounds.height).to eq(60) }
    end

    context "when checking third child positioning" do
      subject(:third_child) { container.children[2] }

      it { expect(third_child.bounds.height).to eq(30) }
      it { expect(third_child.bounds.y).to eq(90) }
    end
  end

  describe "#view" do
    subject(:container) { container_class.new(width: 100, height: 90, title: "header", footer: "footer") }

    it { expect(container.view).to include("Model: header") }
    it { expect(container.view).to include("Model: footer") }
  end
end
