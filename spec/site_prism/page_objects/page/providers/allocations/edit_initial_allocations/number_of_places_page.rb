module PageObjects
  module Page
    module Providers
      module Allocations
        module EditInitialAllocations
          class NumberOfPlacesPage < PageObjects::Base
            set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations/{provider_code}/edit_initial_allocations/number_of_places"

            element :header, "h1"
            element :number_of_places_field, "#allocation-number-of-places-field"
          end
        end
      end
    end
  end
end
