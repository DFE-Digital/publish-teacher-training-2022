module PageObjects
  module Page
    module Organisations
      module Courses
        class NewStudyModePage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/full-part-time/new{?query*}"

          section :study_mode_fields, '[data-qa="course__study_mode"]' do
            element :full_time_label, '[for="course_study_mode_full_time"]'
            element :part_time_label, '[for="course_study_mode_part_time"]'
            element :full_time_or_part_time_label, '[for="course_study_mode_full_time_or_part_time"]'

            element :full_time, "#course_study_mode_full_time"
            element :part_time, "#course_study_mode_part_time"
            element :full_time_or_part_time, "#course_study_mode_full_time_or_part_time"
          end
        end
      end
    end
  end
end
