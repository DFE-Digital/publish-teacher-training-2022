module PageObjects
  module Page
    module Organisations
      class CourseStudyMode < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/full-part-time'

        element :study_mode_fields, '[data-qa="course__study_mode"]'
      end
    end
  end
end
