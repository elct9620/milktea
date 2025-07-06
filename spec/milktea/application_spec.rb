# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea::Application do
  let(:test_model_class) do
    Class.new(Milktea::Model) do
      def self.name
        "TestModel"
      end

      def view
        "Test View"
      end

      def update(_message)
        [self, Milktea::Message::None.new]
      end
    end
  end

  let(:test_app_class) do
    Class.new(described_class) do
      def self.name
        "TestApp"
      end

      root "TestModel"
    end
  end

  let(:config) { Milktea::Config.new }
  let(:loader) { instance_double(Milktea::Loader) }
  let(:program) { instance_double(Milktea::Program) }

  before do
    stub_const("TestModel", test_model_class)
    allow(Milktea::Loader).to receive(:new).and_return(loader)
    allow(Milktea::Program).to receive(:new).and_return(program)
    allow(loader).to receive(:setup)
    allow(loader).to receive(:hot_reload)
    allow(program).to receive(:run)
  end

  after do
    # Reset the app after each test to prevent interference
    Milktea.app = nil
  end

  describe ".inherited" do
    context "when creating a new application class" do
      let(:app_class) do
        Class.new(described_class) do
          def self.name
            "TestInheritedApp"
          end
        end
      end

      before { app_class } # Trigger class creation

      it { expect(Milktea.app).to eq(app_class) }
    end
  end

  describe ".root" do
    context "when setting root model name" do
      subject(:app_class) { Class.new(described_class) }

      before { app_class.root("TestModel") }

      it { expect(app_class.root).to eq("TestModel") }
    end

    context "when getting root model name" do
      subject { test_app_class.root }

      it { is_expected.to eq("TestModel") }
    end
  end

  describe ".root_model_class" do
    subject { test_app_class.root_model_class }

    it { is_expected.to eq(test_model_class) }

    context "when no root model is defined" do
      subject(:app_class) { Class.new(described_class) }

      it { expect(app_class.root_model_class).to be_nil }
    end
  end

  describe "#initialize" do
    subject(:app) { test_app_class.new(config: config) }

    it { expect(app.config).to eq(config) }

    context "when setting up loader" do
      before { app }

      it { expect(Milktea::Loader).to have_received(:new).with(config) }
      it { expect(loader).to have_received(:setup) }
    end

    context "when setting up program with root model" do
      before { app }

      it { expect(Milktea::Program).to have_received(:new).with(an_instance_of(test_model_class), config: config) }
    end

    context "when no config is provided" do
      subject(:app) { test_app_class.new }

      before do
        allow(Milktea).to receive(:config).and_return(config)
      end

      it { expect(app.config).to eq(config) }
    end

    context "when no root model is defined" do
      subject(:app_class) { Class.new(described_class) }

      it { expect { app_class.new }.to raise_error(Milktea::Error, 'No root model defined. Use \'root "ModelName"\' in your Application class.') }
    end
  end

  describe "#run" do
    subject(:app) { test_app_class.new(config: config) }

    context "when hot reloading is enabled" do
      before do
        allow(config).to receive(:hot_reloading?).and_return(true)
      end

      before { app.run }

      it { expect(loader).to have_received(:hot_reload) }
      it { expect(program).to have_received(:run) }
    end

    context "when hot reloading is disabled" do
      before do
        allow(config).to receive(:hot_reloading?).and_return(false)
      end

      before { app.run }

      it { expect(loader).not_to have_received(:hot_reload) }
      it { expect(program).to have_received(:run) }
    end
  end

  describe "#loader" do
    subject(:app) { test_app_class.new(config: config) }

    it { expect(app.loader).to eq(loader) }
  end

  describe "#program" do
    subject(:app) { test_app_class.new(config: config) }

    it { expect(app.program).to eq(program) }
  end

  describe ".boot" do
    context "when root model is defined" do
      subject(:app_instance) { instance_double(test_app_class, run: nil) }

      before do
        allow(test_app_class).to receive(:new).and_return(app_instance)
      end

      before { test_app_class.boot }

      it { expect(test_app_class).to have_received(:new) }
      it { expect(app_instance).to have_received(:run) }
    end

    context "when no root model is defined" do
      subject(:app_class) { Class.new(described_class) }

      it { expect { app_class.boot }.to raise_error(Milktea::Error, 'No root model defined. Use \'root "ModelName"\' in your Application class.') }
    end
  end
end
