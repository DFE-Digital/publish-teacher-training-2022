module PageObjects
  module Page
    module Organisations
      module Courses
        class NewAccreditedBodyPage < CourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/accredited-body/new{?query*}"
        end
      end
    end
  end
end
