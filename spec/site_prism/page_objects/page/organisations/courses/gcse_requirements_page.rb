module PageObjects
  module Page
    module Organisations
      module Courses
        class GcseRequirementsPage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/gcses-pending-or-equivalency-tests{?query*}"

          element :yes_radio, '[data-qa="gcse_requirements__yes_radio"]'
          element :no_radio, '[data-qa="gcse_requirements__no_radio"]'

          element :yes_radio, '[data-qa="gcse_requirements__yes_radio"]'
          element :english_equivalency, '[data-qa="gcse_requirements__english_equivalency"]'
          element :maths_equivalency, '[data-qa="gcse_requirements__maths_equivalency"]'
          element :science_equivalency, '[data-qa="gcse_requirements__science_equivalency"]'
          element :additional_requirements, '[data-qa="gcse_requirements__additional_requirements"]'
          element :no_radio, '[data-qa="gcse_requirements__no_radio"]'

          element :save, '[data-qa="gcse_requirements__save"]'
        end
      end
    end
  end
end
