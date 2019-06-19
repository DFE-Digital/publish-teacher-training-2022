module PageObjects
  module Page
    module Organisations
      class CourseSalary < CourseBase
        set_url '/organisations/{provider_code}/courses/{course_code}/salary'

        element :course_length_one_year, '#course_course_length_oneyear'
        element :course_length_two_years, '#course_course_length_twoyears'
        element :course_salary_details, '#course_salary_details'
      end
    end
  end
end
