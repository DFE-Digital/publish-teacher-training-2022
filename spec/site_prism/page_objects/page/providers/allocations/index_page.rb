module PageObjects
  module Page
    module Providers
      module Allocations
        class IndexPage < PageObjects::Base
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations"

          element :request_again_header, '[data-qa="request-again-header"]'

          sections :rows, "tbody tr" do
            element :provider_name, '[data-qa="provider-name"]'
            element :status, "td[:nth-child(1)"
            element :actions, "td[:nth-child(2)"
          end

          elements :view_requested_confirmation_links, '[data-qa="view-yes-confirmation"]'
          elements :view_not_requested_confirmation_links, '[data-qa="view-no-confirmation"]'
        end
      end
    end
  end
end
