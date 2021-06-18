module PageObjects
  module Page
    module Organisations
      module Courses
        module Degrees
          class StartPage < NewCourseBase
            set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/degrees/start{?query*}"

            element :save, '[data-qa="start__save"]'
            element :yes_radio, '[data-qa="start__yes_radio"]'
            element :no_radio, '[data-qa="start__no_radio"]'
          end
        end
      end
    end
  end
end
