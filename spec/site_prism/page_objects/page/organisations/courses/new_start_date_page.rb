module PageObjects
  module Page
    module Organisations
      module Courses
        class StartDatePage < CourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/start_date/new"
        end
      end
    end
  end
end
