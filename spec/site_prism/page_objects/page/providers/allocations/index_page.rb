module PageObjects
  module Page
    module Providers
      module Allocations
        class IndexPage < PageObjects::Base
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations"

          sections :rows, "tbody tr" do
            element :status, "td[:nth-child(1)"
            element :actions, "td[:nth-child(2)"
          end
        end
      end
    end
  end
end
