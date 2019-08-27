module PageObjects
  module Page
    module Organisations
      class CourseConfirmation < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/confirmation'

        element :qualifications, '[data-qa=course__qualifications]'
      end
    end
  end
end
