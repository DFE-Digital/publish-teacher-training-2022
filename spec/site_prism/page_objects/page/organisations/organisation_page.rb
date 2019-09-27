module PageObjects
  module Page
    module Organisations
      class OrganisationPage < PageObjects::Base
        set_url "/organisations/{provider_code}"

        element :locations, "[data-qa=provider__locations]", text: "Locations"
        element :courses, "[data-qa=provider__courses]", text: "Courses"
        element :current_cycle, "[data-qa=provider__courses__current_cycle]", text: "Current cycle"
        element :next_cycle, "[data-qa=provider__courses__next_cycle]", text: "Next cycle"
      end
    end
  end
end
