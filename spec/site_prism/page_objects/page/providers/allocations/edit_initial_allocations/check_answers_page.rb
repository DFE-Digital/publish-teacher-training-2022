module PageObjects
  module Page
    module Providers
      module Allocations
        module EditInitialAllocations
          class CheckAnswersPage < PageObjects::Base
            set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations/{provider_code}/edit_initial_allocations/check_answers"

            element :header, "h1"
            element :number_of_places, ".govuk-summary-list__value"
            element :change_link, ".govuk-summary-list__actions .govuk-link"
            element :send_request_button, "input[value='Send request']"
          end
        end
      end
    end
  end
end
