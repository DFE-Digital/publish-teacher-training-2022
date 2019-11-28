module PageObjects
  module Page
    module Organisations
      module Courses
        class NewModernLanguagesPage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/modern-languages/new{?query*}"

          element :languages_fields, '[data-qa="course__languages"]'

          def language_checkbox(name)
            languages_fields.find("[data-qa=\"checkbox_language_#{name}\"]")
          end
        end
      end
    end
  end
end
