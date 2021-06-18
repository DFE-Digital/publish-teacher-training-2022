module PageObjects
  module Page
    module Organisations
      module Courses
        module Degrees
          class GradePage < NewCourseBase
            set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/degrees/grade{?query*}"

            element :save, '[data-qa="degree_grade__save"]'
            element :two_one, '[data-qa="degree_grade__two_one"]'
            element :two_two, '[data-qa="degree_grade__two_two"]'
            element :third_class, '[data-qa="degree_grade__third_class"]'
          end
        end
      end
    end
  end
end
