module PageObjects
  module Page
    module Organisations
      class CourseAgeRange < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/age-range'

        element :age_range_fields, '[data-qa="course__age_range_in_years"]'
      end
    end
  end
end
