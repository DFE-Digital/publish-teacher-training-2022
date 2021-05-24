module PageObjects
  module Page
    module Organisations
      class CourseLocations < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/locations"

        element :success_summary, ".govuk-notification-banner--success"
        element :error_summary, ".govuk-error-summary"
        element :save_button, "[data-qa=course__save]"
      end
    end
  end
end
