require "rails_helper"

RSpec.describe InitialRequestForm do
  describe "validations" do
    context "when no radio button selected" do
      it "returns an error" do
        subject.valid?
        expect(subject.errors[:training_provider_code]).to be_present
      end
    end

    context "when no search query provided" do
      subject do
        described_class.new(training_provider_code: "-1")
      end

      it "returns an error" do
        subject.valid?
        expect(subject.errors[:training_provider_query]).to be_present
      end
    end

    context "when search query contains only one character" do
      subject do
        described_class.new(training_provider_code: "-1", training_provider_query: "x")
      end

      it "returns an error" do
        subject.valid?
        expect(subject.errors[:training_provider_query]).to be_present
      end
    end

    context "when search query contains more than one character" do
      subject do
        described_class.new(training_provider_code: "-1", training_provider_query: "ox")
      end

      it "is valid" do
        expect(subject.valid?).to eq(true)
      end
    end
  end
end
