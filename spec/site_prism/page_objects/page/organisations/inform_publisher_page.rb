module PageObjects
  module Page
    module Organisations
      class InformPublisherPage < PageObjects::Base
        set_url "/access-requests/{id}/inform-publisher"

        element :dfe_signin_search_link, "[data-qa=\"dfe_signin_search_link\"]"
        element :notify_service_link, "[data-qa=\"notify_service_link\"]"
        element :registered_user_link, "[data-qa=\"registered_user_link\"]"
        element :unregistered_user_link, "[data-qa=\"unregistered_user_link\"]"
        element :done, "[data-qa=\"done_link\"]"
      end
    end
  end
end
