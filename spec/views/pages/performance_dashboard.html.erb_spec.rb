require "rails_helper"

describe "pages/performance_dashboard" do
  let(:performance_dashboard_page) { PageObjects::Page::PerformanceDashboardPage.new }

  before do
    service = double PerformanceDashboardService,
                     total_providers: "1,000",
                     total_courses: "555",
                     total_users: "3,000",
                     total_allocations: "300",
                     providers_published_courses: "3,400",
                     providers_unpublished_courses: "2,000",
                     providers_accredited_bodies: "2,999",
                     allocations_requests: "1,000",
                     allocations_providers: "2,000",
                     allocations_number_of_places: "3,000",
                     allocations_accredited_bodies: "4,000"

    assign(:performance_data, service)
    render
    performance_dashboard_page.load(rendered)
  end

  it "has a page heading" do
    expect(performance_dashboard_page.page_heading).to have_text("Service performance")
  end

  describe "high level performance indicators" do
    it "has 4 sections" do
      expect(performance_dashboard_page.primary_indicators.length).to eq(4)
    end
  end

  describe "allocations tab" do
    it "has two recruitment cycle years worth of data" do
      expect(performance_dashboard_page.allocation_tab.recruitment_cycles.length).to eq(2)
    end
  end
end
