module PageObjects
  module Page
    module Providers
      module Allocations
        class NumberOfPlacesPage < PageObjects::Base
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations/request"

          element :header, "h1"
          element :number_of_places_field, "#number-of-places-field"
        end
      end
    end
  end
end
