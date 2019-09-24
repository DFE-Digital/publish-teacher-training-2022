module PageObjects
  module Page
    module Organisations
      class CourseAccreditedBodySearch < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/accredited-body/search{?query*}"

        elements :accredited_body_options, '[data-qa="course__accredited_body_option"]'
        element :save, '[data-qa="course__save"]'
      end
    end
  end
end
