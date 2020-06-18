module PageObjects
  module Page
    module Organisations
      class OrganisationShow < CourseBase
        set_url "/organisations/{provider_code}/"

        element :courses_as_accredited_body_link, "a", text: "Courses as an accredited body"
        element :request_allocations_link, "a", text: "Request PE courses for"
        element :notifications_preference_link, "[data-qa='notifications-link']"
      end
    end
  end
end
