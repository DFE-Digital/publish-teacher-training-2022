module PageObjects
  module Page
    module Organisations
      class OrganisationShow < CourseBase
        set_url "/organisations/{provider_code}/"

        element :courses_as_accredited_body_link, "[data-qa=courses_as_accredited_body_link]"
      end
    end
  end
end
