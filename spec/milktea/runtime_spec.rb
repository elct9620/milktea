# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea::Runtime do
  let(:test_model_class) do
    Class.new(Milktea::Model) do
      def view
        "Count: #{state[:count]}"
      end

      def update(message)
        case message
        when :increment
          [with(count: state[:count] + 1), Milktea::Message::None.new]
        when :exit
          [self, Milktea::Message::Exit.new]
        else
          [self, Milktea::Message::None.new]
        end
      end

      private

      def default_state
        { count: 0 }
      end
    end
  end

  let(:model) { test_model_class.new }
  subject(:runtime) { described_class.new }

  describe "#initialize" do
    it { expect(runtime).not_to be_running }
    it { expect(runtime).not_to be_render }
  end

  describe "#start" do
    before { runtime.start }

    it { expect(runtime).to be_running }
  end

  describe "#stop" do
    before do
      runtime.start
      runtime.stop
    end

    it { expect(runtime).not_to be_running }
    it { expect(runtime).to be_stop }
  end

  describe "#enqueue" do
    before { runtime.enqueue(:increment) }

    it "processes message in tick" do
      new_model = runtime.tick(model)
      expect(new_model.state[:count]).to eq(1)
    end
  end

  describe "#tick" do
    context "with no messages" do
      subject(:new_model) { runtime.tick(model) }

      it { expect(new_model).to eq(model) }
      it { expect(runtime).not_to be_render }
    end

    context "with increment message" do
      before do
        runtime.enqueue(:increment)
        @new_model = runtime.tick(model)
      end

      it { expect(@new_model.state[:count]).to eq(1) }
      it { expect(runtime).to be_render }
    end

    context "with exit message" do
      before { runtime.enqueue(:exit) }

      it "stops runtime when processing exit message" do
        runtime.start
        runtime.tick(model)
        expect(runtime).not_to be_running
      end
    end

    context "with None message" do
      before do
        runtime.enqueue(Milktea::Message::None.new)
        runtime.tick(model)
      end

      it { expect(runtime).not_to be_render }
    end

    context "with Resize message" do
      before do
        allow(TTY::Screen).to receive(:width).and_return(80)
        allow(TTY::Screen).to receive(:height).and_return(24)
        runtime.enqueue(Milktea::Message::Resize.new)
        runtime.tick(model)
      end

      it { expect(runtime).to be_render }
    end
  end
end
