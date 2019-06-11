module PageObjects
  module Page
    module Organisations
      class CourseAbout < PageObjects::Base
        set_url '/organisations/{provider_code}/courses/{course_code}/about'

        element :title, '.govuk-heading-xl'
        element :caption, '.govuk-caption-xl'
        element :about_textarea, '#course_about_course'
        element :interview_process_textarea, '#course_interview_process'
        element :how_school_placements_work_textarea, '#course_how_school_placements_work'
        element :warning_message, '[data-copy-course=warning]'
        element :flash, '.govuk-success-summary'
        element :warning_message, '[data-copy-course=warning]'
      end
    end
  end
end
