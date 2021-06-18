module Courses
  module Degrees
    class GradeController < BaseController
      def edit
        @grade_form = GradeForm.build_from_course(@course)
      end

      def update
        @grade_form = GradeForm.new(grade: grade_params)

        if @course.level == "primary" && @grade_form.save(@course)
          redirect_to provider_recruitment_cycle_course_path
        elsif @grade_form.save(@course)
          redirect_to degrees_subject_requirements_provider_recruitment_cycle_course_path
        else
          @errors = @grade_form.errors.messages
          render :edit
        end
      end

    private

      def grade_params
        params.dig(:courses_degrees_grade_form, :grade)
      end
    end
  end
end
