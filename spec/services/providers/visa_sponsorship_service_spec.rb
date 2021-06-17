require "rails_helper"

describe Providers::VisaSponsorshipService do
  describe "#visa_sponsorship_enabled?" do
    it "returns true when feature is enabled and year is 2022" do
      allow(Settings.features.rollover).to receive(:prepare_for_next_cycle).and_return(true)
      provider = build(
        :provider,
        recruitment_cycle: build(:recruitment_cycle, year: 2022),
      )
      expect(described_class.new(provider).visa_sponsorship_enabled?).to be(true)
    end

    it "returns false when feature is NOT enabled and year is 2022" do
      allow(Settings.features.rollover).to receive(:prepare_for_next_cycle).and_return(false)
      provider = build(
        :provider,
        recruitment_cycle: build(:recruitment_cycle, year: 2022),
      )
      expect(described_class.new(provider).visa_sponsorship_enabled?).to be(false)
    end

    it "returns false when feature is enabled and year is 2021" do
      allow(Settings.features.rollover).to receive(:prepare_for_next_cycle).and_return(true)
      provider = build(
        :provider,
        recruitment_cycle: build(:recruitment_cycle, year: 2021),
      )
      expect(described_class.new(provider).visa_sponsorship_enabled?).to be(false)
    end
  end
end
