module PageObjects
  module Page
    class LocationsPage < PageObjects::Base
      set_url '/organisations/{provider_code}/locations'

      element :success_summary, '.govuk-success-summary'
      element :title, 'h1'
      sections :locations, 'tbody tr' do
        element :link, 'a'
        element :cell, '[data-qa=provider__location-name]'
      end
      element :add_a_location_link, "a[href*=\"/locations/new\"]"
    end
  end
end
