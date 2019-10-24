module PageObjects
  module Page
    module Organisations
      class CourseModernLanguages < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/modern-languages"

        element :languages_fields, '[data-qa="course__languages"]'
        element :save, '[data-qa="course__save"]'
      end
    end
  end
end
