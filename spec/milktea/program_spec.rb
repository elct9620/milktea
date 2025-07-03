# frozen_string_literal: true

require "spec_helper"
require "stringio"

RSpec.describe Milktea::Program do
  let(:test_model_class) do
    Class.new(Milktea::Model) do
      def view
        "Hello from Milktea!"
      end

      def update(_message)
        [self, Milktea::Message::None.new]
      end
    end
  end

  let(:model) { test_model_class.new }
  let(:output) { StringIO.new }
  subject(:program) { described_class.new(model, output: output) }

  describe "#initialize" do
    it { expect(program.instance_variable_get(:@model)).to eq(model) }
    it { expect(program.instance_variable_get(:@output)).to eq(output) }
  end

  describe "#running?" do
    context "when program is not started" do
      it { is_expected.not_to be_running }
    end

    context "when program is running" do
      before { program.instance_variable_set(:@running, true) }

      it { is_expected.to be_running }
    end
  end

  describe "#render" do
    before { program.send(:render) }

    it { expect(output.string).to include("Hello from Milktea!") }
  end
end
