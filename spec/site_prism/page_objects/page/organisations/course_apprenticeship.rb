module PageObjects
  module Page
    module Organisations
      class CourseApprenticeship < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/apprenticeship'

        element :program_type_fields, '[data-qa="course__program_type"]'
      end
    end
  end
end
