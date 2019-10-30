module PageObjects
  module Page
    module Organisations
      module Courses
        class NewStartDatePage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/start-date/new{?query*}"
        end
      end
    end
  end
end
