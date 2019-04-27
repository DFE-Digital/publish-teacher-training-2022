module PageObjects
  module Page
    module Organisations
      class OrganisationPage < PageObjects::Base
        set_url '/organisations/{provider_code}'

        element :locations, '[data-qa=provider__locations]'
      end
    end
  end
end
