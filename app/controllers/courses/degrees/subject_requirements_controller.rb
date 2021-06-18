module Courses
  module Degrees
    class SubjectRequirementsController < BaseController
      before_action :redirect_to_course_details_page_if_course_is_primary

      def edit
        set_backlink
        @subject_requirements_form = SubjectRequirementsForm.build_from_course(@course)
      end

      def update
        @subject_requirements_form = SubjectRequirementsForm.new(subject_requirements_params)

        if @subject_requirements_form.save(@course)
          flash[:success] = "Your changes have been saved"

          redirect_to provider_recruitment_cycle_course_path
        else
          set_backlink
          @errors = @subject_requirements_form.errors.messages
          render :edit
        end
      end

    private

      def subject_requirements_params
        params
          .require(:courses_degrees_subject_requirements_form)
          .permit(:additional_degree_subject_requirements, :degree_subject_requirements)
      end

      def set_backlink
        @backlink = if @course.degree_grade == "not_required"
                      degrees_start_provider_recruitment_cycle_course_path
                    else
                      degrees_grade_provider_recruitment_cycle_course_path
                    end
      end

      def redirect_to_course_details_page_if_course_is_primary
        redirect_to provider_recruitment_cycle_course_path if @course.level == "primary"
      end
    end
  end
end
