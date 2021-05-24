module PageObjects
  module Page
    module Organisations
      module Courses
        class NewCourseBase < CourseBase
          element :success_summary, ".govuk-notification-banner--success"
          element :error_flash, ".govuk-error-summary"
          element :error_messages, ".govuk-error-message"
          element :continue, '[data-qa="course__save"]'
          element :back, '[data-qa="page-back"]'
        end
      end
    end
  end
end
