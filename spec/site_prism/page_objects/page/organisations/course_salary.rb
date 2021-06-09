module PageObjects
  module Page
    module Organisations
      class CourseSalary < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/salary"

        element :enrichment_form, '[data-qa="enrichment-form"]'
        element :course_length_one_year, '[data-qa="course_course_length_oneyear"]'
        element :course_length_two_years, '[data-qa="course_course_length_twoyears"]'
        element :course_length_other_length, '[data-qa="course_course_length_other_length"]'
        element :course_salary_details, '[data-qa="course_salary_details"]'
      end
    end
  end
end
