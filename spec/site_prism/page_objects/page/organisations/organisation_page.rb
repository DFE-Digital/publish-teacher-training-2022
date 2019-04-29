module PageObjects
  module Page
    module Organisations
      class OrganisationPage < PageObjects::Base
        set_url '/organisations/{provider_code}'

        element :locations, '[data-qa=provider__locations]', text: 'Locations'
        element :courses, '[data-qa=provider__courses]', text: 'Courses'
      end
    end
  end
end
