module PageObjects
  module Page
    module Organisations
      class CourseApprenticeship < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/apprenticeship"

        element :funding_type_fields, '[data-qa="course__funding_type"]'
        element :funding_type_apprenticeship, '[data-qa="course__funding_type_apprenticeship"]'
        element :funding_type_fee, '[data-qa="course__funding_type_fee"]'
        element :save, '[data-qa="course__save"]'
      end
    end
  end
end
