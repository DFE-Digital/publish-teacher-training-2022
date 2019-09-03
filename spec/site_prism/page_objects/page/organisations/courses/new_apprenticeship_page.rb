module PageObjects
  module Page
    module Organisations
      module Courses
        class NewApprenticeshipPage < CourseBase
          set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/apprenticeship/new'
        end
      end
    end
  end
end
