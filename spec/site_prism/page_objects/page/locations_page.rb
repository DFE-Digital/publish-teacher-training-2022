module PageObjects
  module Page
    class LocationsPage < PageObjects::Base
      set_url "/organisations/{provider_code}/{recruitment_cycle_year}/locations"

      element :success_summary, ".govuk-notification-banner--success"
      element :title, "h1"
      sections :locations, "tbody tr" do
        element :hyperlink, "th a"
        element :cell, "[data-qa=provider__location-name]"
        element :delete_link, "[data-qa=location__delete-link]"
      end
      element :add_a_location_link, "a[href*=\"/locations/new\"]"
    end
  end
end
