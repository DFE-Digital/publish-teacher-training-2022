require "rails_helper"

describe "pages/performance_dashboard" do
  let(:performance_dashboard_page) { PageObjects::Page::PerformanceDashboardPage.new }

  before do
    assign(:performance_data, mock_service)
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

  describe "courses tab" do
    it "reports on 4 sets of figures" do
      expect(performance_dashboard_page.courses_tab.data_sets.length).to eq(4)
    end
  end

  describe "users tab" do
    it "has four user data results" do
      expect(performance_dashboard_page.user_tab.data_sets.length).to eq(4)
    end
  end

  describe "allocations tab" do
    it "has two recruitment cycle years worth of data" do
      expect(performance_dashboard_page.allocation_tab.recruitment_cycles.length).to eq(2)
    end
  end

  describe "rollover tab" do
    before do
      allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(true)
      assign(:performance_data, mock_service)
      render
      performance_dashboard_page.load(rendered)
    end

    it "has five sets of figures" do
      expect(performance_dashboard_page.rollover_tab.data_sets.length).to eq(5)
    end
  end

private

  def mock_service
    @mock_service ||= double PerformanceDashboardService,
                             total_providers: "1,000",
                             total_courses: "555",
                             total_users: "3,000",
                             total_allocations: "300",
                             providers_published_courses: "3,400",
                             providers_unpublished_courses: "2,000",
                             providers_accredited_bodies: "2,999",
                             courses_total_open: "4,999",
                             courses_total_closed: "5,999",
                             courses_total_draft: "6,999",
                             allocations_requests: "1,000",
                             allocations_providers: "2,000",
                             allocations_number_of_places: "3,000",
                             allocations_accredited_bodies: "4,000",
                             users_active: "1,111",
                             users_not_active: "2,222",
                             users_active_30_days: "3,333",
                             published_courses: "2000",
                             new_courses_published: "1000",
                             deleted_courses: "200",
                             existing_courses_in_draft: "500",
                             existing_courses_in_review: "5000"
  end
end
