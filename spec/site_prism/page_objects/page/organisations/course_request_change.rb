module PageObjects
  module Page
    module Organisations
      class CourseRequestChange < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/request-change'
      end
    end
  end
end
