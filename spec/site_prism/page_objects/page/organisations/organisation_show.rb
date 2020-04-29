module PageObjects
  module Page
    module Organisations
      class OrganisationShow < CourseBase
        set_url "/organisations/{provider_code}/"

        element :courses_as_accredited_body_link, "[data-qa=courses_as_accredited_body_link]"
        element :request_allocations_link, "[data-qa=request_allocations_link]"
        element :notifications_preference_link, "[data-qa='notifications-link']"
      end
    end
  end
end
