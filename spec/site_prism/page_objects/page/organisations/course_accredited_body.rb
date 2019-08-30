module PageObjects
  module Page
    module Organisations
      class CourseAccreditedBody < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/accredited-body'

        element :accredited_body_fields, '[data-qa="course__accredited_body"]'
      end
    end
  end
end
