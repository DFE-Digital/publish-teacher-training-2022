module PageObjects
  module Page
    module Providers
      module Allocations
        class NewPage < PageObjects::Base
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations/{training_provider_code}/new"

          element :form, "form"
          element :yes, "#allocation-request-type-repeat-field"
          element :no, "#allocation-request-type-declined-field"
          element :continue_button, "input[value='Continue']"
        end
      end
    end
  end
end
