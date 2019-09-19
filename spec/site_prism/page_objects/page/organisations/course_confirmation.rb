module PageObjects
  module Page
    module Organisations
      class CourseConfirmation < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/confirmation{?query*}"

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
