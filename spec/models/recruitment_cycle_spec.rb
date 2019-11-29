describe RecruitmentCycle do
  describe "#current" do
    let(:provider) { build(:provider, recruitment_cycle: recruitment_cycle) }
    let(:recruitment_cycle) { build(:recruitment_cycle) }

    it "returns the appropriate providers" do
      stub_api_v2_resource(recruitment_cycle, include: "providers")
      Thread.current[:manage_courses_backend_token] = ""
      expect(RecruitmentCycle.current.id).to eq(recruitment_cycle.id)
    end
  end

  describe "#title" do
    context "current cycle and open" do
      let(:recruitment_cycle) { build(:recruitment_cycle) }

      it "displays as the current cycle" do
        allow(Settings).to receive(:current_cycle).and_return(2020)
        allow(Settings).to receive(:current_cycle_open).and_return(true)
        expect(recruitment_cycle.title).to eq("Current cycle (2020 – 2021)")
      end
    end

    context "current cycle" do
      let(:recruitment_cycle) { build(:recruitment_cycle) }

      it "displays as the new cycle" do
        allow(Settings).to receive(:current_cycle).and_return(2020)
        allow(Settings).to receive(:current_cycle_open).and_return(false)
        expect(recruitment_cycle.title).to eq("New cycle (2020 – 2021)")
      end
    end

    context "next cycle" do
      let(:recruitment_cycle) { build(:recruitment_cycle, year: 2020) }

      it "displays as the new cycle" do
        allow(Settings).to receive(:current_cycle).and_return(2019)
        allow(Settings).to receive(:current_cycle_open).and_return(false)
        expect(recruitment_cycle.title).to eq("Next cycle (2020 – 2021)")
      end
    end

    context "previous cycle" do
      let(:recruitment_cycle) { build(:recruitment_cycle, year: 2019) }

      it "displays as the previous cycle" do
        allow(Settings).to receive(:current_cycle).and_return(2020)
        allow(Settings).to receive(:current_cycle_open).and_return(false)
        expect(recruitment_cycle.title).to eq("2019 – 2020")
      end
    end
  end
end
