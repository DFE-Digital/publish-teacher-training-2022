module PageObjects
  module Page
    module Organisations
      class CourseAbout < CourseBase
        set_url '/organisations/{provider_code}/courses/{course_code}/about'

        element :about_textarea, '#course_about_course'
        element :interview_process_textarea, '#course_interview_process'
        element :how_school_placements_work_textarea, '#course_how_school_placements_work'
      end
    end
  end
end
