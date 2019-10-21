module PageObjects
  module Page
    module Organisations
      module Courses
        class NewLocationsPage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/locations/new{?query*}"

          elements :site_names, '[data-qa="site__name"]'
        end
      end
    end
  end
end
