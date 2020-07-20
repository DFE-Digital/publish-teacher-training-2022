module PageObjects
  module Page
    module Organisations
      class CourseAbout < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/about"

        element :enrichment_form, '[data-qa="enrichment-form"]'
        element :about_textarea, "#course-about-course-field"
        element :interview_process_textarea, "#course-interview-process-field"
        element :how_school_placements_work_textarea, "#course-how-school-placements-work-field"
      end
    end
  end
end
