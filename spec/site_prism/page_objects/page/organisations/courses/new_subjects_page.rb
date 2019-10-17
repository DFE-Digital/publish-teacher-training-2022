module PageObjects
  module Page
    module Organisations
      module Courses
        class NewSubjectsPage < CourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/subjects/new{?query*}"

          element :subjects_fields, '[data-qa="course__subjects"]'
          element :continue, '[data-qa="course__save"]'
        end
      end
    end
  end
end
