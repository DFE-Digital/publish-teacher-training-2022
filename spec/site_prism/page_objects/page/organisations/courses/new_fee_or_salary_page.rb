module PageObjects
  module Page
    module Organisations
      module Courses
        class NewFeeOrSalaryPage < CourseBase
          set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/fee-or-salary/new'

          section :program_type_fields, '[data-qa="course__program_type"]' do
            element :pg_teaching_apprenticeship, '#course_program_type_pg_teaching_apprenticeship'
            element :school_direct_training_programme, '#course_program_type_school_direct_training_programme'
            element :school_direct_salaried_training_programme, '#course_program_type_school_direct_salaried_training_programme'
          end
        end
      end
    end
  end
end
