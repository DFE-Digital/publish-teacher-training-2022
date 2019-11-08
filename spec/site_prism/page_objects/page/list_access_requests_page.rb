module PageObjects
  module Page
    class ListAccessRequestsPage < PageObjects::Base
      set_url "/access-requests"

      elements :access_requests, "[data-qa=\"access-request\"]"
    end
  end
end
