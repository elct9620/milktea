# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea do
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
          config.app_dir = "custom"
          config.hot_reloading = false
        end
      end

      it { expect(config.app_dir).to eq("custom") }
      it { expect(config.hot_reloading?).to be(false) }
    end

    context "when called multiple times" do
      before do
        described_class.configure do |config|
          config.app_dir = "first"
        end

        described_class.configure do |config|
          config.app_dir = "second"
        end
      end

      it { expect(config.app_dir).to eq("second") }
    end
  end
end
