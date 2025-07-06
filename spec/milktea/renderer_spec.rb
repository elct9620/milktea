# frozen_string_literal: true

require "spec_helper"
require "stringio"

RSpec.describe Milktea::Renderer do
  let(:test_model_class) do
    Class.new(Milktea::Model) do
      def view
        "Hello from Renderer!"
      end

      def update(_message)
        [self, Milktea::Message::None.new]
      end
    end
  end

  let(:model) { test_model_class.new }
  let(:custom_output) { StringIO.new }

  describe "output behavior" do
    context "with default output" do
      subject(:renderer) { described_class.new }

      before do
        allow(TTY::Screen).to receive(:size).and_return([80, 24])
      end

      it { expect { renderer.render(model) }.to output.to_stdout }
    end

    context "with custom output" do
      subject(:renderer) { described_class.new(custom_output) }

      before do
        allow(TTY::Screen).to receive(:size).and_return([80, 24])
        renderer.render(model)
      end

      it { expect(custom_output.string).to include("Hello from Renderer!") }
    end
  end

  describe "#render" do
    subject(:renderer) { described_class.new(custom_output) }

    before do
      allow(TTY::Screen).to receive(:size).and_return([80, 24])
      renderer.render(model)
    end

    it { expect(custom_output.string).to include("Hello from Renderer!") }
  end

  describe "#setup_screen" do
    subject(:renderer) { described_class.new(custom_output) }

    before do
      allow(TTY::Screen).to receive(:size).and_return([80, 24])
      renderer.setup_screen
    end

    it { expect(custom_output.string).not_to be_empty }
  end

  describe "#restore_screen" do
    subject(:renderer) { described_class.new(custom_output) }

    before do
      allow(TTY::Screen).to receive(:size).and_return([80, 24])
      renderer.restore_screen
    end

    it { expect(custom_output.string).not_to be_empty }
  end

  describe "#resize?" do
    subject(:renderer) { described_class.new(custom_output) }

    before do
      allow(TTY::Screen).to receive(:size).and_return([80, 24])
    end

    context "when screen size hasn't changed" do
      it { expect(renderer.resize?).to be(false) }
    end

    context "when screen size has changed" do
      before do
        allow(TTY::Screen).to receive(:size).and_return([80, 24], [100, 30])
      end

      it { expect(renderer.resize?).to be(true) }
    end

    context "when checking resize multiple times after size change" do
      before do
        allow(TTY::Screen).to receive(:size).and_return([80, 24], [100, 30], [100, 30])
        renderer.resize? # First call detects change
      end

      it { expect(renderer.resize?).to be(false) }
    end
  end
end
