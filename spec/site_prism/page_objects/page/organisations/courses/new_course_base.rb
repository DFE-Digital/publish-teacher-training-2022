module PageObjects
  module Page
    module Organisations
      module Courses
        class NewCourseBase < CourseBase
          element :continue, '[data-qa="course__save"]'
        end
      end
    end
  end
end
