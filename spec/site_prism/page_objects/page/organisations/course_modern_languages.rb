module PageObjects
  module Page
    module Organisations
      class CourseModernLanguages < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/modern-languages"

        element :languages_fields, '[data-qa="course__languages"]'
        element :save_button, '[data-qa="course__save"]'

        def language_checkbox(name)
          languages_fields.find("[data-qa=\"checkbox_language_#{name}\"]")
        end
      end
    end
  end
end
