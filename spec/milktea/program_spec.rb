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
  let(:runtime) { instance_double(Milktea::Runtime) }
  subject(:program) { described_class.new(model, runtime: runtime, output: output) }

  describe "#initialize" do
    it { expect(program.instance_variable_get(:@model)).to eq(model) }
    it { expect(program.instance_variable_get(:@runtime)).to eq(runtime) }
    it { expect(program.instance_variable_get(:@output)).to eq(output) }
  end

  describe "#running?" do
    before { allow(runtime).to receive(:running?).and_return(running_state) }

    context "when runtime is not running" do
      let(:running_state) { false }

      it { is_expected.not_to be_running }
    end

    context "when runtime is running" do
      let(:running_state) { true }

      it { is_expected.to be_running }
    end
  end

  describe "#render" do
    before { program.send(:render) }

    it { expect(output.string).to include("Hello from Milktea!") }
  end

  describe "#stop" do
    before do
      allow(runtime).to receive(:stop)
      program.stop
    end

    it { expect(runtime).to have_received(:stop) }
  end
end
