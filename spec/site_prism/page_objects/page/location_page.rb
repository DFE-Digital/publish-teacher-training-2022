module PageObjects
  module Page
    class LocationPage < PageObjects::Base
      set_url '/organisations/{provider_code}/{recruitment_cycle_year}/locations/{site_id}/edit'
      set_url_matcher(%r{/organisations/.*?/.*?/locations/\d+(/edit)?$})

      element :title, 'h1'
      element :name_field, 'input[data-qa="location_name"]'
      element :publish_changes, '[data-qa="location__publish-changes"]'
      element :error_summary, '.govuk-error-summary'
    end
  end
end
