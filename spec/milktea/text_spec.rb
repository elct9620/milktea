# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea::Text do
  describe "#initialize" do
    context "with content in state" do
      subject(:text) { described_class.new(content: "Hello, World!") }

      it { expect(text.state[:content]).to eq("Hello, World!") }
    end

    context "with bounds in state" do
      subject(:text) { described_class.new(content: "Test", width: 40, height: 10, x: 5, y: 5) }

      it { expect(text.bounds.width).to eq(40) }
      it { expect(text.bounds.height).to eq(10) }
      it { expect(text.bounds.x).to eq(5) }
      it { expect(text.bounds.y).to eq(5) }
    end

    context "with default state" do
      subject(:text) { described_class.new }

      it { expect(text.state[:content]).to eq("") }
    end
  end

  describe "#view" do
    context "with empty content" do
      subject(:text) { described_class.new(content: "") }

      it { expect(text.view).to eq("") }
    end

    context "with simple text that fits within bounds" do
      subject(:text) { described_class.new(content: "Hello", width: 10, height: 5) }

      it { expect(text.view).to include("Hello") }
      it { expect(text.view).to include(TTY::Cursor.move_to(0, 0)) }
    end

    context "with text requiring wrapping" do
      subject(:text) do
        described_class.new(
          content: "This is a very long line that needs to be wrapped",
          width: 10,
          height: 10
        )
      end

      let(:output) { text.view }
      let(:lines) { output.split(/\e\[\d+;\d+H/).reject(&:empty?) }

      it { expect(lines[0]).to eq("This is a ") }
      it { expect(lines[1]).to eq("very long ") }
      it { expect(lines[2]).to eq("line that ") }
      it { expect(lines[3]).to eq("needs to ") }
      it { expect(lines[4]).to eq("be wrapped") }
    end

    context "with text exceeding height bounds" do
      subject(:text) do
        described_class.new(
          content: "Line 1\nLine 2\nLine 3 that is very long and will " \
                   "definitely be truncated because it exceeds width\nLine 4\nLine 5",
          width: 20,
          height: 3
        )
      end

      let(:output) { text.view }
      let(:visible_lines) { output.split(/\e\[\d+;\d+H/).reject(&:empty?) }

      it { expect(visible_lines.size).to eq(3) }
      it { expect(visible_lines[0]).to include("Line 1") }
      it { expect(visible_lines[1]).to include("Line 2") }
      it { expect(visible_lines[2]).to include("Line 3 that is very ") }
    end

    context "with wrapped text exceeding height bounds" do
      subject(:text) do
        described_class.new(
          content: "This is a very long text that will wrap into multiple lines and exceed the height bounds",
          width: 10,
          height: 3
        )
      end

      let(:output) { text.view }
      let(:visible_lines) { output.split(/\e\[\d+;\d+H/).reject(&:empty?) }

      it { expect(visible_lines.size).to eq(3) }
      it { expect(visible_lines.last).to include("text that ") }
    end

    context "with unicode and emoji text" do
      subject(:text) do
        described_class.new(
          content: "Hello 世界 🌍",
          width: 12,
          height: 5
        )
      end

      it { expect(text.view).to include("Hello 世界 🌍") }
    end

    context "with unicode text requiring truncation" do
      subject(:text) do
        described_class.new(
          content: "ラドクリフ、マラソン五輪代表に1万m出場にも含み",
          width: 8,
          height: 10
        )
      end

      let(:output) { text.view }
      let(:lines) { output.split(/\e\[\d+;\d+H/).reject(&:empty?) }

      it { expect(lines[0]).to eq("ラドクリ") }
      it { expect(lines[1]).to eq("フ、マラ") }
      it { expect(lines[2]).to eq("ソン五輪") }
    end

    context "with custom positioning" do
      subject(:text) do
        described_class.new(
          content: "Positioned",
          width: 20,
          height: 5,
          x: 10,
          y: 5
        )
      end

      it { expect(text.view).to include(TTY::Cursor.move_to(10, 5)) }
      it { expect(text.view).to include("Positioned") }
    end

    context "with multiline content and positioning" do
      subject(:text) do
        described_class.new(
          content: "Line 1\nLine 2",
          width: 20,
          height: 5,
          x: 10,
          y: 5
        )
      end

      it { expect(text.view).to include(TTY::Cursor.move_to(10, 5)) }
      it { expect(text.view).to include(TTY::Cursor.move_to(10, 6)) }
    end
  end

  describe "immutability" do
    let(:text) { described_class.new(content: "Original") }

    context "when updating with new state" do
      subject(:new_text) { text.with(content: "Updated") }

      it { is_expected.not_to be(text) }
      it { expect(new_text.state[:content]).to eq("Updated") }
      it { expect(text.state[:content]).to eq("Original") }
    end
  end
end
