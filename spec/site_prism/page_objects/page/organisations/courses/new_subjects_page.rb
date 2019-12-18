module PageObjects
  module Page
    module Organisations
      module Courses
        class NewSubjectsPage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/subjects/new{?query*}"

          element :title, '[data-qa="page-heading"]'
          element :subjects_fields, '[data-qa="course__subjects"]'
          element :master_subject_fields, '[data-qa="course__master_subject"]'
          element :subordinate_subject_accordion, '[data-qa="course__subordinate_subject_accordion"]'
          element :subordinate_subjects_fields, '[data-qa="course__subordinate_subjects"]'
          element :continue, '[data-qa="course__save"]'
        end
      end
    end
  end
end
