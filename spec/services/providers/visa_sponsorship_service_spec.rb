require "rails_helper"

describe Providers::VisaSponsorshipService do
  describe "#visa_sponsorship_enabled?" do
    it "returns true when recruitment cycle year is 2022" do
      provider = build(
        :provider,
        recruitment_cycle: build(:recruitment_cycle, year: 2022),
      )
      expect(described_class.new(provider).visa_sponsorship_enabled?).to be(true)
    end

    it "returns false when recruitment cycle year is 2021" do
      provider = build(
        :provider,
        recruitment_cycle: build(:recruitment_cycle, year: 2021),
      )
      expect(described_class.new(provider).visa_sponsorship_enabled?).to be(false)
    end
  end
end
