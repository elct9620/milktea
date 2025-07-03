# frozen_string_literal: true

require "spec_helper"

RSpec.describe Milktea::Command do
  describe "::None" do
    subject(:command) { described_class::None.new }

    it { is_expected.to be_a(Data) }
    it { is_expected.to eq(described_class::None.new) }
  end

  describe "::Exit" do
    subject(:command) { described_class::Exit.new }

    it { is_expected.to be_a(Data) }
    it { is_expected.to eq(described_class::Exit.new) }
  end

  describe "::Tick" do
    subject(:command) { described_class::Tick.new }

    it { is_expected.to be_a(Data) }
    it { is_expected.to eq(described_class::Tick.new) }
  end

  describe "::Batch" do
    subject(:command) { described_class::Batch.new(commands: commands) }

    let(:commands) { [described_class::None.new, described_class::Exit.new] }

    it { is_expected.to be_a(Data) }
    it { expect(command.commands).to eq(commands) }

    context "with default commands" do
      subject(:command) { described_class::Batch.new }

      it { expect(command.commands).to eq([]) }
    end
  end
end
