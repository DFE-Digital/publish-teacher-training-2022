module PageObjects
  module Page
    module Organisations
      module Courses
        class NewAgeRangePage < CourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/age-range/new{?query*}"

          element :age_range_fields, '[data-qa="course__age_range_in_years"]'
        end
      end
    end
  end
end
