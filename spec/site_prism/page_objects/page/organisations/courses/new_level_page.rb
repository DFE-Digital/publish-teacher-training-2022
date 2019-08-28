module PageObjects
  module Page
    module Organisations
      module Courses
        class NewLevelPage < CourseBase
          set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/level/new'
        end
      end
    end
  end
end
