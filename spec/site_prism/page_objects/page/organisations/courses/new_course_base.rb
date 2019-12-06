module PageObjects
  module Page
    module Organisations
      module Courses
        class NewCourseBase < CourseBase

          element :success_summary, ".govuk-success-summary"
          element :error_flash, ".govuk-error-summary"
          element :continue, '[data-qa="course__save"]'
        end
      end
    end
  end
end
