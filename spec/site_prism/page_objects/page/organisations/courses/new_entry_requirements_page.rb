module PageObjects
  module Page
    module Organisations
      module Courses
        class NewEntryRequirementsPage < CourseBase
          set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/entry-requirements/new'

          element :maths_requirements,   '[data-qa="course__maths"]'
          element :english_requirements, '[data-qa="course__english"]'
          element :science_requirements, '[data-qa="course__science"]'
        end
      end
    end
  end
end
