require "rails_helper"

describe EditInitialRequestForm do
  describe "validations" do
    context "when no radio button selected" do
      it "returns an error" do
        subject.valid?
        expect(subject.errors[:request_type]).to be_present
      end
    end

    context "when number_of_places is empty" do
      subject do
        described_class.new(number_of_places: "")
      end

      it "returns an error" do
        subject.valid?
        expect(subject.errors[:number_of_places]).to be_present
      end
    end

    context "when number_of_places is less than 1" do
      subject do
        described_class.new(number_of_places: "0")
      end

      it "returns an error" do
        subject.valid?
        expect(subject.errors[:number_of_places]).to be_present
      end
    end

    context "when number_of_places contains a letter" do
      subject do
        described_class.new(number_of_places: "3a")
      end

      it "returns an error" do
        subject.valid?
        expect(subject.errors[:number_of_places]).to be_present
      end
    end

    context "when number of places is a float" do
      subject do
        described_class.new(number_of_places: "1.1")
      end

      it "returns an error" do
        subject.valid?
        expect(subject.errors[:number_of_places]).to be_present
      end
    end

    context "when all valid parameters are passed in" do
      subject do
        described_class.new(request_type: AllocationsView::RequestType::INITIAL, number_of_places: "2")
      end

      it "is valid" do
        expect(subject.valid?).to eq(true)
      end
    end
  end
end
