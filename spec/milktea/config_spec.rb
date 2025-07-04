# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea::Config do
  subject(:config) { described_class.new }

  describe "#initialize" do
    it { expect(config.app_dir).to eq("app") }
    it { expect([true, false]).to include(config.hot_reloading) }
    it { expect(config.reloader).to be_a(Milktea::Reloader) }

    context "when providing block configuration" do
      subject(:custom_config) do
        described_class.new do |c|
          c.app_dir = "src"
          c.hot_reloading = false
        end
      end

      it { expect(custom_config.app_dir).to eq("src") }
      it { expect(custom_config.hot_reloading).to be(false) }
    end
  end

  describe "#hot_reloading" do
    context "when not explicitly set" do
      before { allow(Milktea).to receive(:env).and_return(:development) }

      it { expect(config.hot_reloading).to be(true) }
    end

    context "when environment is production" do
      before { allow(Milktea).to receive(:env).and_return(:production) }

      it { expect(config.hot_reloading).to be(false) }
    end

    context "when explicitly set to true" do
      before { config.hot_reloading = true }

      it { expect(config.hot_reloading).to be(true) }
    end

    context "when explicitly set to false" do
      before { config.hot_reloading = false }

      it { expect(config.hot_reloading).to be(false) }
    end
  end

  describe "#reloader" do
    context "when not explicitly set" do
      it { expect(config.reloader).to be_a(Milktea::Reloader) }
    end

    context "when explicitly set" do
      let(:custom_reloader) { instance_double(Milktea::Reloader) }

      before { config.reloader = custom_reloader }

      it { expect(config.reloader).to be(custom_reloader) }
    end
  end

  describe "#app_path" do
    before { allow(Milktea).to receive(:root).and_return(Pathname.new("/project")) }

    it { expect(config.app_path).to eq(Pathname.new("/project/app")) }

    context "when app_dir is customized" do
      before { config.app_dir = "src" }

      it { expect(config.app_path).to eq(Pathname.new("/project/src")) }
    end
  end
end
