module Courses
  module Degrees
    class StartController < BaseController
      def edit
        @start_form = StartForm.new
        @start_form.set_attributes(@course)
      end

      def update
        @start_form = StartForm.new(degree_grade_required: grade_required_params)

        if @course.level == "primary" && @start_form.save(@course)
          redirect_to provider_recruitment_cycle_course_path
        elsif @start_form.save(@course)
          redirect_to degrees_subject_requirements_provider_recruitment_cycle_course_path
        elsif @start_form.degree_grade_required.present?
          redirect_to degrees_grade_provider_recruitment_cycle_course_path
        else
          @errors = @start_form.errors.messages
          render :edit
        end
      end

    private

      def grade_required_params
        params.dig(:courses_degrees_start_form, :degree_grade_required)
      end
    end
  end
end
