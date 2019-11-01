module PageObjects
  module Page
    module Organisations
      class CourseAgeRange < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/age-range"

        element :age_range_fields, '[data-qa="course__age_range_in_years"]'
        element :age_range_14_to_19, '[data-qa="course__age_range_in_years_14_to_19_radio"]'
        element :age_range_other, '[data-qa="course__age_range_in_years_other_radio"]'
        element :age_range_from_field, '[data-qa="course__age_range_in_years_other_from_input"]'
        element :age_range_to_field, '[data-qa="course__age_range_in_years_other_to_input"]'
        element :save, '[data-qa="course__save"]'
      end
    end
  end
end
