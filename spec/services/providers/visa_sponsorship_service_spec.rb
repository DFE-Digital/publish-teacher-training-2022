require "rails_helper"

describe Providers::VisaSponsorshipService do
  describe "#show_visa_sponsorship?" do
    it "returns true when feature is enabled, year is 2022 and provider as not declared sponsorship" do
      allow(Settings.features.rollover).to receive(:prepare_for_next_cycle).and_return(true)
      provider = build(
        :provider,
        can_sponsor_student_visa: nil,
        recruitment_cycle: build(:recruitment_cycle, year: 2022),
      )
      expect(described_class.new(provider).show_visa_sponsorship?).to be(true)
    end

    it "returns false when feature is NOT enabled, year is 2022 and provider as not declared sponsorship" do
      allow(Settings.features.rollover).to receive(:prepare_for_next_cycle).and_return(false)
      provider = build(
        :provider,
        can_sponsor_student_visa: nil,
        recruitment_cycle: build(:recruitment_cycle, year: 2022),
      )
      expect(described_class.new(provider).show_visa_sponsorship?).to be(false)
    end

    it "returns false when feature is enabled, year is 2021 and provider as not declared sponsorship" do
      allow(Settings.features.rollover).to receive(:prepare_for_next_cycle).and_return(true)
      provider = build(
        :provider,
        can_sponsor_student_visa: nil,
        recruitment_cycle: build(:recruitment_cycle, year: 2021),
      )
      expect(described_class.new(provider).show_visa_sponsorship?).to be(false)
    end

    it "returns false when feature is enabled, year is 2022 and provider has already declared sponsorship" do
      allow(Settings.features.rollover).to receive(:prepare_for_next_cycle).and_return(true)
      provider = build(
        :provider,
        recruitment_cycle: build(:recruitment_cycle, year: 2022),
      )
      expect(described_class.new(provider).show_visa_sponsorship?).to be(false)
    end
  end
end
