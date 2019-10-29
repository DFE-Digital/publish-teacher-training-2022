module PageObjects
  module Page
    module Organisations
      module Courses
        class NewAccreditedBodySearchPage < CourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/accredited-body/search_new{?query*}"

          elements :accredited_body_options, '[data-qa="course__accredited_body_option"]'
          element :continue, '[data-qa="course__save"]'
        end
      end
    end
  end
end
