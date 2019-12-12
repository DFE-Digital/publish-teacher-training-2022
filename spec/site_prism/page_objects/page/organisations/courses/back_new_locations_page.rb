module PageObjects
  module Page
    module Organisations
      module Courses
        class BackNewLocationsPage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/locations/back{?query*}"
        end
      end
    end
  end
end
