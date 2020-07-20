module PageObjects
  module Page
    module Providers
      module Allocations
        module EditInitialAllocations
          class DoYouWantPage < PageObjects::Base
            set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations/{provider_code}/edit_initial_allocations/do_you_want"

            element :page_heading, '[data-qa="page-heading"]'
            element :yes, "#request-type-initial-field"
            element :no, "#request-type-declined-field"
          end
        end
      end
    end
  end
end
