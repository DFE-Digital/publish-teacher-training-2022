module PageObjects
  module Page
    module Organisations
      module Courses
        class NewModernLanguagesPage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/modern-languages/back{?query*}"
        end
      end
    end
  end
end
