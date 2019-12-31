module PageObjects
  module Page
    module Organisations
      module Courses
        class NewAgeRangePage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/age-range/new{?query*}"

          element :age_range_fields, '[data-qa="course__age_range_in_years"]'
          element :age_range_other, '[data-qa="course__age_range_in_years_other_radio"]'
          element :age_range_from_field, '[data-qa="course__age_range_in_years_other_from_input"]'
          element :age_range_to_field, '[data-qa="course__age_range_in_years_other_to_input"]'
        end
      end
    end
  end
end
