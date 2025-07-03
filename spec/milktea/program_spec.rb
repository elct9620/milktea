# frozen_string_literal: true

require "spec_helper"
require "stringio"

RSpec.describe Milktea::Program do
  subject(:program) { described_class.new(output: output) }

  let(:output) { StringIO.new }

  describe "#run" do
    before { program.run }

    it { expect(output.string).to include("Hello from Milktea!") }
  end

  describe "#running?" do
    context "when program is not started" do
      it { is_expected.not_to be_running }
    end

    context "when program is running" do
      before { program.instance_variable_set(:@running, true) }

      it { is_expected.to be_running }
    end
  end
end
