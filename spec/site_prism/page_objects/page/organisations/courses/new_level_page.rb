module PageObjects
  module Page
    module Organisations
      module Courses
        class NewLevelPage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/level/new"

          section :level_fields, '[data-qa="course__level"]' do
            element :primary, '[data-qa="course__primary"]'
            element :secondary, '[data-qa="course__secondary"]'
            element :further_education, '[data-qa="course__further_education"]'
          end
        end
      end
    end
  end
end
