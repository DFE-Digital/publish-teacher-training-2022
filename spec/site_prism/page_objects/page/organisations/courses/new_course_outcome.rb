module PageObjects
  module Page
    module Organisations
      module Courses
        class NewCourseOutcome < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/outcome/new{?query*}"

          element :qualification_fields, '[data-qa="course__qualification"]'
        end
      end
    end
  end
end
