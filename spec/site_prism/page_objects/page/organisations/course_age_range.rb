module PageObjects
  module Page
    module Organisations
      class CourseAgeRange < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/age-range"

        element :age_range_14_to_19, "#course-age-range-in-years-14-to-19-field"
        element :age_range_other, "#course-age-range-in-years-other-field"
        element :age_range_from_field, "#course-course-age-range-in-years-other-from-field"
        element :age_range_to_field, "#course-course-age-range-in-years-other-to-field"
        element :save, 'input[type="submit"]'
      end
    end
  end
end
