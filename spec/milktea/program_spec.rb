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
  let(:config) { instance_double(Milktea::Config, runtime: runtime, renderer: renderer, output: output) }
  subject(:program) { described_class.new(model, config: config) }

  describe "#running?" do
    context "when runtime is not running" do
      let(:runtime) { spy("runtime", running?: false) }
      let(:config) { instance_double(Milktea::Config, runtime: runtime, renderer: renderer, output: output) }

      it { is_expected.not_to be_running }
    end

    context "when runtime is running" do
      let(:runtime) { spy("runtime", running?: true) }
      let(:config) { instance_double(Milktea::Config, runtime: runtime, renderer: renderer, output: output) }

      it { is_expected.to be_running }
    end
  end

  describe "default config creation" do
    subject(:program_with_default_config) { described_class.new(model) }

    it { expect { program_with_default_config }.not_to raise_error }
  end

  describe "#initialize" do
    it { expect { program }.not_to raise_error }

    context "when custom config is provided" do
      let(:custom_config) { Milktea::Config.new { |c| c.autoload_dirs = ["custom"] } }
      subject(:program_with_config) { described_class.new(model, config: custom_config) }

      it { expect { program_with_config }.not_to raise_error }
    end
  end

  describe "#stop" do
    before { program.stop }

    it { expect(runtime).to have_received(:stop) }
  end
end
