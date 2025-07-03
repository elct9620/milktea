# frozen_string_literal: true

require "spec_helper"
require "stringio"

RSpec.describe Milktea::Program do
  describe "#run" do
    it "outputs text to the specified output" do
      output = StringIO.new
      program = described_class.new(output: output)

      program.run

      expect(output.string).to include("Hello from Milktea!")
    end
  end
end
