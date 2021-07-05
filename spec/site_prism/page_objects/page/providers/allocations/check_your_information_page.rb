module PageObjects
  module Page
    module Providers
      module Allocations
        class CheckYourInformationPage < PageObjects::Base
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations/request"

          element :header, "h1"
          element :number_of_places, ".govuk-summary-list__value"
          element :change_link, ".govuk-summary-list__actions .govuk-link"
          element :send_request_button, '[data-qa="allocations__send_request"]'
        end
      end
    end
  end
end
