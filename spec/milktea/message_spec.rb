# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea::Message do
  describe "Resize" do
    before do
      allow(TTY::Screen).to receive(:width).and_return(80)
      allow(TTY::Screen).to receive(:height).and_return(24)
    end

    subject(:resize_message) { described_class::Resize.new }

    it { expect(resize_message.width).to eq(80) }
    it { expect(resize_message.height).to eq(24) }
    it { expect(resize_message).to be_frozen }

    context "when initializing with custom dimensions" do
      subject(:custom_resize_message) { described_class::Resize.new(width: 100, height: 30) }

      it { expect(custom_resize_message.width).to eq(100) }
      it { expect(custom_resize_message.height).to eq(30) }
    end
  end
end
