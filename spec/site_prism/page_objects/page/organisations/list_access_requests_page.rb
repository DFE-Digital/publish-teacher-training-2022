module PageObjects
  module Page
    module Organisations
      class ListAccessRequestsPage < PageObjects::Base
        set_url "/access-requests"
        element :create_access_request, "[data-qa=\"create-access-request\"]"

        sections :access_requests, "[data-qa=\"access-request\"]" do
          element :id, "[data-qa=\"access-request__id\"]"
          element :request_date, "[data-qa=\"access-request__request_date\"]"
          element :requester, "[data-qa=\"access-request__requester\"]"
          element :recipient, "[data-qa=\"access-request__recipient\"]"
          element :approve, "[data-qa=\"access-request__approve\"]"
          element :organisation, "[data-qa=\"access-request__organisation\"]"
        end
      end
    end
  end
end
