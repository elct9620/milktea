# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea::Container do
  let(:test_model_class) do
    Class.new(described_class) do
      def view
        "Test Container"
      end

      def update(_message)
        [self, Milktea::Message::None.new]
      end
    end
  end

  let(:child_model_class) do
    Class.new(described_class) do
      def view
        "Child: #{state[:name]}"
      end

      def update(_message)
        [self, Milktea::Message::None.new]
      end
    end
  end

  describe "#initialize" do
    context "with bounds in state" do
      subject(:container) { test_model_class.new(width: 100, height: 80, x: 10, y: 20) }

      it { expect(container.bounds.width).to eq(100) }
      it { expect(container.bounds.height).to eq(80) }
      it { expect(container.bounds.x).to eq(10) }
      it { expect(container.bounds.y).to eq(20) }
    end

    context "with default bounds" do
      subject(:container) { test_model_class.new }

      before do
        allow(TTY::Screen).to receive(:width).and_return(80)
        allow(TTY::Screen).to receive(:height).and_return(24)
      end

      it { expect(container.bounds.width).to eq(80) }
      it { expect(container.bounds.height).to eq(24) }
      it { expect(container.bounds.x).to eq(0) }
      it { expect(container.bounds.y).to eq(0) }
    end

    context "with explicit dimension override" do
      subject(:container) { test_model_class.new(width: 100, height: 50) }

      it { expect(container.bounds.width).to eq(100) }
      it { expect(container.bounds.height).to eq(50) }
      it { expect(container.bounds.x).to eq(0) }
      it { expect(container.bounds.y).to eq(0) }
    end

    context "when bounds are extracted from state" do
      subject(:container) { test_model_class.new(width: 100, height: 50, name: "test") }

      it { expect(container.state[:name]).to eq("test") }
      it { expect(container.state).not_to have_key(:width) }
      it { expect(container.state).not_to have_key(:height) }
    end
  end

  describe ".child" do
    let(:container_with_children) do
      Class.new(described_class) do
        child Class.new(Milktea::Model), flex: 1
        child Class.new(Milktea::Model), ->(state) { { value: state[:parent_value] } }, flex: 2
      end
    end

    it { expect(container_with_children.children.size).to eq(2) }

    context "when examining first child definition" do
      subject(:first_child) { container_with_children.children.first }

      it { expect(first_child[:class]).to be_a(Class) }
      it { expect(first_child[:mapper]).to be_a(Proc) }
      it { expect(first_child[:flex]).to eq(1) }
    end

    context "when examining second child definition" do
      subject(:second_child) { container_with_children.children.last }

      it { expect(second_child[:flex]).to eq(2) }
    end
  end

  describe "#children" do
    let(:parent_container_class) do
      header_class = Class.new(Milktea::Model) do
        def view
          "Header"
        end
      end

      content_class = Class.new(Milktea::Model) do
        def view
          "Content"
        end
      end

      Class.new(described_class) do
        direction :column
        child header_class, ->(state) { { name: state[:header_name] } }, flex: 1
        child content_class, flex: 2
      end
    end

    let(:parent_container) { parent_container_class.new(width: 100, height: 90, header_name: "header") }

    it { expect(parent_container.children.size).to eq(2) }

    context "when checking first child layout" do
      subject(:first_child) { parent_container.children.first }

      it { expect(first_child.state[:width]).to eq(100) }
      it { expect(first_child.state[:height]).to eq(30) }
      it { expect(first_child.state[:x]).to eq(0) }
      it { expect(first_child.state[:y]).to eq(0) }
    end

    context "when checking second child layout" do
      subject(:second_child) { parent_container.children.last }

      it { expect(second_child.state[:width]).to eq(100) }
      it { expect(second_child.state[:height]).to eq(60) }
      it { expect(second_child.state[:x]).to eq(0) }
      it { expect(second_child.state[:y]).to eq(30) }
    end

    context "when checking child state mapping" do
      subject(:first_child) { parent_container.children.first }

      it { expect(first_child.state[:name]).to eq("header") }
    end
  end

  describe "flexbox layout calculation" do
    let(:equal_flex_container) do
      Class.new(described_class) do
        direction :column
        child Class.new(Milktea::Model), flex: 1
        child Class.new(Milktea::Model), flex: 1
        child Class.new(Milktea::Model), flex: 1
      end
    end

    let(:container) { equal_flex_container.new(width: 90, height: 90) }

    context "when checking equal flex distribution" do
      subject(:child_heights) { container.children.map { |c| c.state[:height] } }

      it { expect(child_heights).to eq([30, 30, 30]) }
    end

    context "when checking double flex distribution" do
      let(:double_flex_container) do
        Class.new(described_class) do
          direction :column
          child Class.new(Milktea::Model), flex: 1
          child Class.new(Milktea::Model), flex: 2
          child Class.new(Milktea::Model), flex: 1
        end
      end

      let(:container) { double_flex_container.new(width: 100, height: 80) }
      subject(:child_heights) { container.children.map { |c| c.state[:height] } }

      it { expect(child_heights).to eq([20, 40, 20]) }
    end
  end

  describe "row layout" do
    let(:row_container_class) do
      Class.new(described_class) do
        direction :row
        child Class.new(Milktea::Model), flex: 1
        child Class.new(Milktea::Model), flex: 2
        child Class.new(Milktea::Model), flex: 1
      end
    end

    let(:container) { row_container_class.new(width: 80, height: 20) }

    context "when checking horizontal distribution" do
      subject(:child_widths) { container.children.map { |c| c.state[:width] } }

      it { expect(child_widths).to eq([20, 40, 20]) }
    end

    context "when checking positions" do
      subject(:child_positions) { container.children.map { |c| [c.state[:x], c.state[:y]] } }

      it { expect(child_positions).to eq([[0, 0], [20, 0], [60, 0]]) }
    end
  end
end
