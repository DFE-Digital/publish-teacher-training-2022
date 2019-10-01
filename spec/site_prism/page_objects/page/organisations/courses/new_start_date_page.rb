module PageObjects
  module Page
    module Organisations
      module Courses
        class NewStartDatePage < CourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/start-date/new{?query*}"

          element :continue, '[data-qa="course__save"]'
        end
      end
    end
  end
end
