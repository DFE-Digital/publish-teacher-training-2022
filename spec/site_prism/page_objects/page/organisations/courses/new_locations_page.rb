module PageObjects
  module Page
    module Organisations
      module Courses
        class NewLocationsPage < CourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/locations/new{?query*}"

          elements :site_names, '[data-qa="site__name"]'
          element :continue, '[data-qa="course__save"]'
        end
      end
    end
  end
end
