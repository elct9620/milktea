# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea::Config do
  subject(:config) { described_class.new }

  describe "#initialize" do
    it { expect(config.app_dir).to eq("app") }
    it { expect(config.output).to eq($stdout) }
    it { expect(config.hot_reloading?).to be(false) }
    it { expect(config.reloader).to be_a(Milktea::Reloader) }
    it { expect(config.runtime).to be_a(Milktea::Runtime) }
    it { expect(config.renderer).to be_a(Milktea::Renderer) }

    context "when providing block configuration" do
      subject(:custom_config) do
        described_class.new do |c|
          c.app_dir = "src"
          c.hot_reloading = false
        end
      end

      it { expect(custom_config.app_dir).to eq("src") }
      it { expect(custom_config.hot_reloading?).to be(false) }
    end
  end

  describe "#hot_reloading?" do
    context "when not explicitly set" do
      before { allow(Milktea).to receive(:env).and_return(:development) }

      it { expect(config.hot_reloading?).to be(true) }
    end

    context "when environment is production" do
      before { allow(Milktea).to receive(:env).and_return(:production) }

      it { expect(config.hot_reloading?).to be(false) }
    end

    context "when explicitly set to true" do
      before { config.hot_reloading = true }

      it { expect(config.hot_reloading?).to be(true) }
    end

    context "when explicitly set to false" do
      before { config.hot_reloading = false }

      it { expect(config.hot_reloading?).to be(false) }
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

  describe "#runtime" do
    context "when not explicitly set" do
      it { expect(config.runtime).to be_a(Milktea::Runtime) }
    end

    context "when explicitly set" do
      let(:custom_runtime) { instance_double(Milktea::Runtime) }

      before { config.runtime = custom_runtime }

      it { expect(config.runtime).to be(custom_runtime) }
    end
  end

  describe "#renderer" do
    context "when not explicitly set" do
      it { expect(config.renderer).to be_a(Milktea::Renderer) }
    end

    context "when explicitly set" do
      let(:custom_renderer) { instance_double(Milktea::Renderer) }

      before { config.renderer = custom_renderer }

      it { expect(config.renderer).to be(custom_renderer) }
    end

    context "when output is customized" do
      let(:custom_output) { StringIO.new }

      before { config.output = custom_output }

      it { expect(config.renderer).to be_a(Milktea::Renderer) }
    end
  end

  describe "#output" do
    context "when not explicitly set" do
      it { expect(config.output).to eq($stdout) }
    end

    context "when explicitly set" do
      let(:custom_output) { StringIO.new }

      before { config.output = custom_output }

      it { expect(config.output).to be(custom_output) }
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
