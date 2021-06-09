module PageObjects
  module Page
    class PerformanceDashboardPage < PageObjects::Base
      set_url "/performance-dashboard"

      element :page_heading, ".govuk-heading-xl"

      sections :primary_indicators, '[data-qa="performance-dashboard-kpi"]' do
        element :section_heading, ".govuk-heading-m"
      end

      section :courses_tab, "#courses" do
        elements :data_sets, '[data-qa="performance-dashboard-stat"]'
      end

      section :user_tab, "#users" do
        elements :data_sets, '[data-qa="performance-dashboard-stat"]'
      end

      section :allocation_tab, "#allocations" do
        elements :recruitment_cycles, ".govuk-grid-row"
      end

      section :rollover_tab, "#rollover" do
        elements :data_sets, '[data-qa="performance-dashboard-stat"]'
      end
    end
  end
end
