module PageObjects
  module Page
    module Organisations
      class CourseSubjects < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/subjects"

        element :subjects_fields, '[data-qa="course__subjects"]'
        element :master_subject_fields, '[data-qa="course__master_subject"]'
        element :save, '[data-qa="course__save"]'
      end
    end
  end
end
