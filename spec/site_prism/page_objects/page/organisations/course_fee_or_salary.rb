module PageObjects
  module Page
    module Organisations
      class CourseFeeOrSalary < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/fee-or-salary'

        section :funding_type_fields, '[data-qa="course__funding_type"]' do
          element :apprenticeship, '[data-qa="course__funding_type_apprenticeship"]'
          element :fee, '[data-qa="course__funding_type_fee"]'
          element :salary, '[data-qa="course__funding_type_salary"]'
        end
        element :save, '[data-qa="course__save"]'
      end
    end
  end
end
