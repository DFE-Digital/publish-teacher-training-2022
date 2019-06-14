module PageObjects
  module Page
    module Organisations
      class CourseBase < PageObjects::Base
        def load_with_course(course)
          self.load(provider_code: course.provider_code, course_code: course.course_code)
        end
      end
    end
  end
end
