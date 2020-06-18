module PageObjects
  module Page
    module Organisations
      class RecruitmentCycle < PageObjects::Base
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}"

        element :title, ".govuk-heading-xl"
        element :caption, ".govuk-caption-xl"

        element :about_organisation_link, "a", text: "About your organisation"
        element :locations_link, "a", text: "Locations"
        element :courses_link, "a", text: "Courses"
        element :courses_as_accredited_body_link, "a", text: "Courses as an accredited body"
      end
    end
  end
end
