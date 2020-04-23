module PageObjects
  module Page
    module Providers
      module Allocations
        class ShowPage < PageObjects::Base
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations/{provider_code}"

          element :page_heading, '[data-qa="page-heading"]'
        end
      end
    end
  end
end
