# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea do
  after do
    # Reset the app after each test to prevent interference
    described_class.app = nil
  end

  it "has a version number" do
    expect(Milktea::VERSION).not_to be nil
  end

  describe ".root" do
    subject { described_class.root }

    it { is_expected.to be_a(Pathname) }
  end

  describe ".env" do
    subject { described_class.env }

    it { is_expected.to be_a(Symbol) }

    context "when MILKTEA_ENV is set" do
      before { allow(ENV).to receive(:fetch).with("MILKTEA_ENV", nil).and_return("test") }

      it { is_expected.to eq(:test) }
    end

    context "when APP_ENV is set" do
      before do
        allow(ENV).to receive(:fetch).with("MILKTEA_ENV", nil).and_return(nil)
        allow(ENV).to receive(:fetch).with("APP_ENV", "production").and_return("staging")
      end

      it { is_expected.to eq(:staging) }
    end

    context "when no environment variables are set" do
      before do
        allow(ENV).to receive(:fetch).with("MILKTEA_ENV", nil).and_return(nil)
        allow(ENV).to receive(:fetch).with("APP_ENV", "production").and_return("production")
      end

      it { is_expected.to eq(:production) }
    end
  end

  describe ".config" do
    subject { described_class.config }

    it { is_expected.to be_a(Milktea::Config) }
  end

  describe ".configure" do
    subject(:config) { described_class.config }

    context "when configuring with block" do
      before do
        described_class.configure do |config|
          config.autoload_dirs = ["custom"]
          config.hot_reloading = false
        end
      end

      it { expect(config.autoload_dirs).to eq(["custom"]) }
      it { expect(config.hot_reloading?).to be(false) }
    end

    context "when called multiple times" do
      before do
        described_class.configure do |config|
          config.autoload_dirs = ["first"]
        end

        described_class.configure do |config|
          config.autoload_dirs = ["second"]
        end
      end

      it { expect(config.autoload_dirs).to eq(["second"]) }
    end
  end

  describe ".app" do
    subject { described_class.app }

    it { is_expected.to be_nil }
  end

  describe ".app=" do
    let(:test_app) { Class.new(Milktea::Application) }

    context "when setting app" do
      before { described_class.app = test_app }

      it { expect(described_class.app).to eq(test_app) }
    end

    context "when setting app to nil" do
      before do
        described_class.app = test_app
        described_class.app = nil
      end

      it { expect(described_class.app).to be_nil }
    end
  end
end
