# frozen_string_literal: true

RSpec.describe Milktea::Loader do
  subject(:loader) { described_class.new(config) }

  let(:config) { spy("config", autoload_paths: autoload_paths, runtime: runtime, hot_reloading?: false) }
  let(:autoload_paths) { [Pathname.new("/path/to/app"), Pathname.new("/path/to/lib")] }
  let(:runtime) { spy("runtime") }

  describe "#initialize" do
    it { is_expected.to be_a(described_class) }
  end

  describe "#setup" do
    let(:zeitwerk_loader) { spy("zeitwerk_loader") }
    let(:zeitwerk_loader_class) { spy("Zeitwerk::Loader") }

    before do
      stub_const("Zeitwerk::Loader", zeitwerk_loader_class)
      allow(zeitwerk_loader_class).to receive(:new).and_return(zeitwerk_loader)
      loader.setup
    end

    it { expect(zeitwerk_loader_class).to have_received(:new) }
    it { expect(zeitwerk_loader).to have_received(:push_dir).with(autoload_paths[0]) }
    it { expect(zeitwerk_loader).to have_received(:push_dir).with(autoload_paths[1]) }
    it { expect(zeitwerk_loader).to have_received(:enable_reloading) }
    it { expect(zeitwerk_loader).to have_received(:setup) }
  end

  describe "#hot_reload" do
    let(:listener) { spy("listener") }
    let(:listen_class) { spy("Listen") }

    before { stub_const("Listen", listen_class) }

    context "when Listen is available" do
      before do
        allow(loader).to receive(:gem).with("listen")
        allow(loader).to receive(:require).with("listen")
        allow(listen_class).to receive(:to).and_return(listener)
        loader.hot_reload
      end

      it { expect(listen_class).to have_received(:to).with(autoload_paths[0], only: /\.rb$/) }
      it { expect(listen_class).to have_received(:to).with(autoload_paths[1], only: /\.rb$/) }
      it { expect(listener).to have_received(:start).twice }
    end

    context "when Listen is not available" do
      before do
        allow(loader).to receive(:gem).with("listen").and_raise(Gem::LoadError)
        allow(listen_class).to receive(:to).and_return(listener)
        loader.hot_reload
      end

      it { expect(listen_class).not_to have_received(:to) }
    end
  end

  describe "#reload" do
    let(:zeitwerk_loader) { spy("zeitwerk_loader") }
    let(:zeitwerk_loader_class) { spy("Zeitwerk::Loader") }

    before { stub_const("Zeitwerk::Loader", zeitwerk_loader_class) }

    context "when loader has been setup" do
      before do
        allow(zeitwerk_loader_class).to receive(:new).and_return(zeitwerk_loader)
        loader.setup
        loader.reload
      end

      it { expect(zeitwerk_loader).to have_received(:reload) }
      it { expect(runtime).to have_received(:enqueue).with(instance_of(Milktea::Message::Reload)) }
    end

    context "when loader has not been setup" do
      before { loader.reload }

      it { expect(zeitwerk_loader).not_to have_received(:reload) }
      it { expect(runtime).not_to have_received(:enqueue) }
    end
  end
end
