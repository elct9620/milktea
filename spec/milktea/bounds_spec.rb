# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea::Bounds do
  describe "#initialize" do
    context "with default values" do
      subject { described_class.new }

      it { expect(subject.width).to eq(0) }
      it { expect(subject.height).to eq(0) }
      it { expect(subject.x).to eq(0) }
      it { expect(subject.y).to eq(0) }
    end

    context "with custom values" do
      subject { described_class.new(width: 100, height: 50, x: 10, y: 20) }

      it { expect(subject.width).to eq(100) }
      it { expect(subject.height).to eq(50) }
      it { expect(subject.x).to eq(10) }
      it { expect(subject.y).to eq(20) }
    end
  end

  describe "immutability" do
    subject { described_class.new(width: 100, height: 50, x: 10, y: 20) }

    it { is_expected.to be_frozen }
  end
end
