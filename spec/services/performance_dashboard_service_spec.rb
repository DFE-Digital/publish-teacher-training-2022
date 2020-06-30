require "rails_helper"

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
      expect(data.total_allocations).to eq("1,183")
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

  describe "courses tab data" do
    it "returns a total number of open courses" do
      data = service.call
      expect(data.courses_total_open).to eq("5,920")
    end

    it "returns a total number of closes courses" do
      data = service.call
      expect(data.courses_total_closed).to eq("7,146")
    end

    it "returns a total number of closes courses" do
      data = service.call
      expect(data.courses_total_draft).to eq("4,631")
    end
  end

  describe "users tab data" do
    it "returns a total of users" do
      data = service.call
      expect(data.total_users).to eq("3,050")
    end

    it "returns a total of active users" do
      data = service.call
      expect(data.users_active).to eq("1,883")
    end

    it "returns a total of inactive users" do
      data = service.call
      expect(data.users_not_active).to eq("1,167")
    end

    it "returns a total of recently active users" do
      data = service.call
      expect(data.users_active_30_days).to eq("1,708")
    end
  end

  describe "allocations tab data" do
    describe "current allocations" do
      it "returns a total of allocations" do
        data = service.call
        expect(data.allocations_requests("current")).to eq("1,183")
      end

      it "returns a total of providers" do
        data = service.call
        expect(data.allocations_number_of_places("current")).to eq("1,677")
      end

      it "returns a total of accredited bodies" do
        data = service.call
        expect(data.allocations_accredited_bodies("current")).to eq("1,186")
      end

      it "returns a total number of places" do
        data = service.call
        expect(data.allocations_providers("current")).to eq("1,180")
      end
    end

    describe "previous allocations" do
      it "returns a total of allocations" do
        data = service.call
        expect(data.allocations_requests("previous")).to eq("1,433")
      end

      it "returns a total of providers" do
        data = service.call
        expect(data.allocations_number_of_places("previous")).to eq("1,461")
      end

      it "returns a total of accredited bodies" do
        data = service.call
        expect(data.allocations_accredited_bodies("previous")).to eq("1,153")
      end

      it "returns a total number of places" do
        data = service.call
        expect(data.allocations_providers("previous")).to eq("1,397")
      end
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
