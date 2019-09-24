module PageObjects
  module Page
    module Organisations
      class CourseOutcome < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/outcome"

        element :qualification_fields, '[data-qa="course__qualification"]'
      end
    end
  end
end
