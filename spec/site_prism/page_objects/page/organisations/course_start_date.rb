module PageObjects
  module Page
    module Organisations
      class CourseStartDate < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/start-date"

        element :start_date_field, '[data-qa="start_date"]'
      end
    end
  end
end
