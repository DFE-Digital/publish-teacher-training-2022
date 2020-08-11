require "rails_helper"

RSpec.describe Allocation do
  describe ".journey_mode" do
    context "when allocation period is open" do
      it "returns 'open'" do
        Settings.features.allocations.state = "open"
        expect(Allocation.journey_mode).to eq("open")
      end
    end

    context "when allocation period is closed" do
      it "returns 'closed'" do
        Settings.features.allocations.state = "closed"
        expect(Allocation.journey_mode).to eq("closed")
      end
    end

    context "when allocation period is confirmed" do
      it "returns 'closed'" do
        Settings.features.allocations.state = "confirmed"
        expect(Allocation.journey_mode).to eq("confirmed")
      end
    end

    context "when allocation period setting is invalid" do
      it "returns 'open by default'" do
        Settings.features.allocations.state = "not_the_correct_state"
        expect(Allocation.journey_mode).to eq("open")
      end
    end
  end

  describe "validations" do
    context "when number_of_places is empty" do
      subject do
        described_class.new(number_of_places: "", request_type: Allocation::RequestTypes::INITIAL)
      end

      it "returns an error" do
        subject.valid?
        expect(subject.errors[:number_of_places]).to be_present
      end
    end

    context "when number_of_places is less than 1" do
      subject do
        described_class.new(number_of_places: "0", request_type: Allocation::RequestTypes::INITIAL)
      end

      it "returns an error" do
        subject.valid?
        expect(subject.errors[:number_of_places]).to be_present
      end
    end

    context "when number_of_places contains a letter" do
      subject do
        described_class.new(number_of_places: "3a", request_type: Allocation::RequestTypes::INITIAL)
      end

      it "returns an error" do
        subject.valid?
        expect(subject.errors[:number_of_places]).to be_present
      end
    end

    context "when number of places is a float" do
      subject do
        described_class.new(number_of_places: "1.1", request_type: Allocation::RequestTypes::INITIAL)
      end

      it "returns an error" do
        subject.valid?
        expect(subject.errors[:number_of_places]).to be_present
      end
    end

    context "when number of places is valid" do
      subject do
        described_class.new(number_of_places: "2", request_type: Allocation::RequestTypes::INITIAL)
      end

      it "is valid" do
        expect(subject.valid?).to eq(true)
      end
    end
  end
end
