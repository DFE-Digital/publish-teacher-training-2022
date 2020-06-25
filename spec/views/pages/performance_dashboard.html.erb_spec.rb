require "rails_helper"

describe "pages/performance_dashboard" do
  let(:performance_dashboard_page) { PageObjects::Page::PerformanceDashboardPage.new }

  before do
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
end
