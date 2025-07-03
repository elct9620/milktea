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

      it "renders to stdout by default" do
        expect { renderer.render(model) }.to output.to_stdout
      end
    end

    context "with custom output" do
      subject(:renderer) { described_class.new(custom_output) }

      before { renderer.render(model) }

      it { expect(custom_output.string).to include("Hello from Renderer!") }
    end
  end

  describe "#render" do
    subject(:renderer) { described_class.new(custom_output) }

    before { renderer.render(model) }

    it { expect(custom_output.string).to include("Hello from Renderer!") }
  end

  describe "#setup_screen" do
    subject(:renderer) { described_class.new(custom_output) }

    before { renderer.setup_screen }

    it { expect(custom_output.string).not_to be_empty }
  end

  describe "#restore_screen" do
    subject(:renderer) { described_class.new(custom_output) }

    before { renderer.restore_screen }

    it { expect(custom_output.string).not_to be_empty }
  end
end
