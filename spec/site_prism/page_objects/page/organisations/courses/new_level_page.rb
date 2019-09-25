module PageObjects
  module Page
    module Organisations
      module Courses
        class NewLevelPage < CourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/level/new"

          section :level_fields, '[data-qa="course__level"]' do
            element :primary,           "#course_level_primary"
            element :secondary,         "#course_level_secondary"
            element :further_education, "#course_level_further_education"
          end

          element :continue, '[data-qa="course__save"]'
        end
      end
    end
  end
end
