# frozen_string_literal: true

RSpec.describe Milktea::Reloader do
  subject(:reloader) { described_class.new(app_dir, runtime) }

  let(:app_dir) { "/path/to/app" }
  let(:runtime) { spy("runtime") }

  describe "#initialize" do
    it { is_expected.to be_a(described_class) }
  end

  describe "#start" do
    before do
      allow(reloader).to receive(:setup_loader)
      reloader.start
    end

    it { expect(reloader).to have_received(:setup_loader) }
  end

  describe "#hot_reload" do
    let(:listener) { spy("listener") }
    let(:listen_class) { spy("Listen") }

    before { stub_const("Listen", listen_class) }

    context "when Listen is available" do
      before do
        allow(reloader).to receive(:gem).with("listen")
        allow(reloader).to receive(:require).with("listen")
        allow(listen_class).to receive(:to).and_return(listener)
        reloader.hot_reload
      end

      it { expect(listen_class).to have_received(:to).with(app_dir, only: /\.rb$/) }
      it { expect(listener).to have_received(:start) }
    end

    context "when Listen is not available" do
      before do
        allow(reloader).to receive(:gem).with("listen").and_raise(Gem::LoadError)
        allow(listen_class).to receive(:to).and_return(listener)
        reloader.hot_reload
      end

      it { expect(listen_class).not_to have_received(:to) }
    end
  end

  describe "#reload" do
    let(:loader) { spy("loader") }
    let(:zeitwerk_loader_class) { spy("Zeitwerk::Loader") }

    before { stub_const("Zeitwerk::Loader", zeitwerk_loader_class) }

    context "when loader has been started" do
      before do
        allow(zeitwerk_loader_class).to receive(:new).and_return(loader)
        reloader.start
        reloader.reload
      end

      it { expect(loader).to have_received(:reload) }
      it { expect(runtime).to have_received(:enqueue).with(instance_of(Milktea::Message::Reload)) }
    end

    context "when loader has not been started" do
      before { reloader.reload }

      it { expect(loader).not_to have_received(:reload) }
      it { expect(runtime).not_to have_received(:enqueue) }
    end
  end

  describe "#setup_loader" do
    let(:loader) { spy("loader") }
    let(:zeitwerk_loader_class) { spy("Zeitwerk::Loader") }

    before do
      stub_const("Zeitwerk::Loader", zeitwerk_loader_class)
      allow(zeitwerk_loader_class).to receive(:new).and_return(loader)
      reloader.send(:setup_loader)
    end

    it { expect(zeitwerk_loader_class).to have_received(:new) }
    it { expect(loader).to have_received(:push_dir).with(app_dir) }
    it { expect(loader).to have_received(:enable_reloading) }
    it { expect(loader).to have_received(:setup) }
  end
end
