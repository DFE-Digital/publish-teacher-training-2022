module PageObjects
  module Page
    module Organisations
      class CourseLevel < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/level'

        element :primary, '[data-qa="course__primary"]'
        element :secondary, '[data-qa="course__secondary"]'
        element :further_education, '[data-qa="course__further_education"]'
      end
    end
  end
end
