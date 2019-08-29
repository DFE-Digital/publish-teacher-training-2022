module PageObjects
  module Page
    module Organisations
      class CourseFeeOrSalary < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/fee-or-salary'

        element :program_type_fields, '[data-qa="course__program_type"]'
      end
    end
  end
end
