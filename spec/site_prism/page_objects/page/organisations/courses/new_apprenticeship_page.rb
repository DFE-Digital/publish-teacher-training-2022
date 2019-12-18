module PageObjects
  module Page
    module Organisations
      module Courses
        class NewApprenticeshipPage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/apprenticeship/new{?query*}"

          element :funding_type_error, '[data-qa="inline-error-funding_type"]'
          element :program_type_error, '[data-qa="inline-error-program_type"]'
          
          section :funding_type_fields, '[data-qa="course__funding_type"]' do
            element :apprenticeship, '[data-qa="course__funding_type_apprenticeship"]'
            element :fee, '[data-qa="course__funding_type_fee"]'
          end
        end
      end
    end
  end
end
