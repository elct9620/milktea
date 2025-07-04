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
  let(:runtime) { spy("runtime", running?: false) }
  let(:renderer) { spy("renderer") }
  subject(:program) { described_class.new(model, runtime: runtime, renderer: renderer) }

  describe "#running?" do
    context "when runtime is not running" do
      let(:runtime) { spy("runtime", running?: false) }

      it { is_expected.not_to be_running }
    end

    context "when runtime is running" do
      let(:runtime) { spy("runtime", running?: true) }

      it { is_expected.to be_running }
    end
  end

  describe "default renderer creation" do
    let(:runtime_for_run) do
      spy("runtime_for_run",
          start: nil,
          running?: false,
          tick: model,
          render?: false)
    end
    subject(:program_with_output) { described_class.new(model, runtime: runtime_for_run, output: output) }

    it "creates a default renderer when none provided" do
      expect { program_with_output.run }.not_to raise_error
    end
  end

  describe "#initialize" do
    it "creates program without errors" do
      expect { program }.not_to raise_error
    end

    context "when custom config is provided" do
      let(:custom_config) { Milktea::Config.new { |c| c.app_dir = "custom" } }
      subject(:program_with_config) { described_class.new(model, config: custom_config) }

      it "creates program with custom config without errors" do
        expect { program_with_config }.not_to raise_error
      end
    end
  end

  describe "#stop" do
    it "delegates to runtime stop" do
      program.stop
      expect(runtime).to have_received(:stop)
    end
  end
end
