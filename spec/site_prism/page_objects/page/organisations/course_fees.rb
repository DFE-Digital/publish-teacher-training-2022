module PageObjects
  module Page
    module Organisations
      class CourseFees < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/fees'

        element :course_length_one_year, '#course_course_length_oneyear'
        element :course_length_two_years, '#course_course_length_twoyears'
        element :course_length_other, '#course_course_length_other'
        element :course_length_other_length, '#course_course_length_other_length'
        element :course_fees_uk_eu, '#course_fee_uk_eu'
        element :course_fees_international, '#course_fee_international'
        element :fee_details, '#course_fee_details'
        element :financial_support, '#course_financial_support'
      end
    end
  end
end
