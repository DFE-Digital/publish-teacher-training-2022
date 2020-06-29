describe PerformanceDashboardService do
  let(:service) { described_class.new }

  before do
    stub_request(:get, "http://localhost:3001/reporting.json")
      .to_return(
        status: 200,
        body: File.new("spec/fixtures/performance-dashboard.json"),
        headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
      )
  end

  describe "4 initial performance indicators" do
    it "returns a total of providers" do
      data = service.call
      expect(data.total_providers).to eq("1,941")
    end

    it "returns a total of courses" do
      data = service.call
      expect(data.total_courses).to eq("13,066")
    end

    it "returns a total of users" do
      data = service.call
      expect(data.total_users).to eq("3,050")
    end

    it "returns a total of allocation for the current recruitment cycle year" do
      data = service.call
      expect(data.total_allocations).to eq("183")
    end
  end

  describe "providers tab data" do
    it "returns a total of providers" do
      data = service.call
      expect(data.total_providers).to eq("1,941")
    end

    it "returns a total of providers with publish courses" do
      data = service.call
      expect(data.providers_published_courses).to eq("1,807")
    end

    it "returns a total of providers with courses not published" do
      data = service.call
      expect(data.providers_unpublished_courses).to eq("2,530")
    end

    it "returns a total of providers who are accredited bodies" do
      data = service.call
      expect(data.providers_accredited_bodies).to eq("1,930")
    end
  end

  describe "when service fails to fetch data" do
    before do
      stub_request(:get, "http://localhost:3001/reporting.json")
        .to_raise(StandardError)
    end

    it "returns false" do
      data = service.call
      expect(data).to eq(false)
    end
  end
end
