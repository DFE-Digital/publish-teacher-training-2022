module PageObjects
  module Page
    class LocationDeletePage < PageObjects::Base
      set_url "/organisations/{provider_code}/{recruitment_cycle_year}/locations/{site_id}/delete"
      set_url_matcher(%r{/organisations/.*?/.*?/locations/\d+(/delete)?$})

      element :confirm_field, 'input[name="site[confirm_location_name]"]'
      element :submit_button, '[data-qa="location__delete"]'
      element :error_summary, ".govuk-error-summary"
    end
  end
end
