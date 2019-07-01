module PageObjects
  module Page
    module Organisations
      class CourseBase < PageObjects::Base
        def load_with_course(course)
          self.load(provider_code: course.provider_code, recruitment_cycle_year: course.recruitment_cycle_year, course_code: course.course_code)
        end

        element :title, '.govuk-heading-xl'
        element :caption, '.govuk-caption-xl'
        element :flash, '.govuk-success-summary'
        element :error_flash, '.govuk-error-summary'
        element :warning_message, '[data-copy-course=warning]'

        section :copy_content, PageObjects::Section::CopyContentSection
      end
    end
  end
end
