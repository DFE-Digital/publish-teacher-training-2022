module PageObjects
  module Page
    class PerformanceDashboardPage < PageObjects::Base
      set_url "/performance-dashboard"

      element :page_heading, ".govuk-heading-xl"

      sections :primary_indicators, ".app-performance-dashboard" do
        element :section_heading, ".govuk-heading-m"
      end
    end
  end
end
