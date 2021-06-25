module PageObjects
  module Page
    module Organisations
      module Courses
        module Degrees
          class SubjectRequirementsPage < NewCourseBase
            set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/degrees/subject-requirements{?query*}"

            element :save, '[data-qa="degree_subject_requirements__save"]'
            element :yes_radio, '[data-qa="degree_subject_requirements__yes_radio"]'
            element :no_radio, '[data-qa="degree_subject_requirements__no_radio"]'
            element :requirements, '[data-qa="degree_subject_requirements__requirements"]'
          end
        end
      end
    end
  end
end
