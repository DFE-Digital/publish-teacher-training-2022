require 'rails_helper'

RSpec.feature 'Recruitment cycle helpers', type: :helper do
  context "viewing a page in the current cycle" do
    before do
      allow(Settings).to receive(:current_cycle).and_return(2019)
      allow(helper).to receive(:params).and_return(recruitment_cycle_year: "2019")
    end

    it "knows it’s the current cycle" do
      expect(helper.current_cycle?).to eq(true)
      expect(helper.next_cycle?).to eq(false)
    end

    it "has the right title" do
      expect(helper.recruitment_cycle_title).to eq("Current cycle (2019 – 2020)")
    end
  end

  context "viewing a page in the next cycle" do
    before do
      allow(Settings).to receive(:current_cycle).and_return(2019)
      allow(helper).to receive(:params).and_return(recruitment_cycle_year: "2020")
    end

    it "knows it’s the next cycle" do
      expect(helper.current_cycle?).to eq(false)
      expect(helper.next_cycle?).to eq(true)
    end

    it "has the right title" do
      expect(helper.recruitment_cycle_title).to eq("Next cycle (2020 – 2021)")
    end
  end

  context "viewing a page in a previous cycle" do
    before do
      allow(Settings).to receive(:current_cycle).and_return(2020)
      allow(helper).to receive(:params).and_return(recruitment_cycle_year: "2019")
    end

    it "knows it’s not the current cycle or the next cycle" do
      expect(helper.current_cycle?).to eq(false)
      expect(helper.next_cycle?).to eq(false)
    end

    it "just shows the years as the title" do
      expect(helper.recruitment_cycle_title).to eq("2019 – 2020")
    end
  end
end
