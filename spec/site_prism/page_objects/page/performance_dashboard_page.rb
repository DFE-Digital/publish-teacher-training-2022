module PageObjects
  module Page
    class PerformanceDashboardPage < PageObjects::Base
      set_url "/performance-dashboard"

      element :page_heading, ".govuk-heading-xl"

      sections :primary_indicators, ".app-performance-dashboard--kpi" do
        element :section_heading, ".govuk-heading-m"
      end

      section :allocation_tab, "#allocations" do
        elements :recruitment_cycles, ".govuk-grid-row"
      end
    end
  end
end
