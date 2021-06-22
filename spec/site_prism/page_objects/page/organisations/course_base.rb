module PageObjects
  module Page
    module Organisations
      class CourseBase < PageObjects::Base
        def load_with_course(course)
          self.load(provider_code: course.provider_code, recruitment_cycle_year: course.recruitment_cycle_year, course_code: course.course_code)
        end

        element :title, ".govuk-heading-l"
        element :legend, ".govuk-fieldset__legend--l .govuk-fieldset__heading"
        element :caption, ".govuk-caption-l"
        element :flash, ".govuk-notification-banner--success"
        element :error_flash, ".govuk-error-summary"
        element :warning_message, '[data-qa="copy-course-warning"]'
        element :back, '[data-qa="page-back"]'
        element :success_summary, ".govuk-notification-banner--success"

        section :copy_content, PageObjects::Section::CopyContentSection
      end
    end
  end
end
