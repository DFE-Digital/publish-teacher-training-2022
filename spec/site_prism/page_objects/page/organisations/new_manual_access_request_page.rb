module PageObjects
  module Page
    module Organisations
      class NewManualAccessRequestPage < PageObjects::Base
        set_url "/access-requests/new_manual"

        element :requester_email, "[data-qa=\"requester_email\"]"
        element :email_address, "[data-qa=\"email_address\"]"
        element :first_name, "[data-qa=\"first_name\"]"
        element :last_name, "[data-qa=\"last_name\"]"
        element :preview, "[data-qa=\"preview\"]"
      end
    end
  end
end
