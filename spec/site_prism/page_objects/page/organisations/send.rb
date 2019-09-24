module PageObjects
  module Page
    module Organisations
      class Send < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/send"

        element :send_field, '[data-qa="is_send"]'
      end
    end
  end
end
