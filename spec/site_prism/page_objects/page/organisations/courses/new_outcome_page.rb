module PageObjects
  module Page
    module Organisations
      module Courses
        class NewOutcomePage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/outcome/new{?query*}"

          section :qualification_fields, '[data-qa="course__qualification"]' do
            element :qts,           "#course_qualification_qts"
            element :pgce,          "#course_qualification_pgce"
            element :pgce_with_qts, "#course_qualification_pgce_with_qts"
            element :pgde_with_qts, "#course_qualification_pgde_with_qts"
          end
        end
      end
    end
  end
end
