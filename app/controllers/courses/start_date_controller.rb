module Courses
  class StartDateController < ApplicationController
    include CourseBasicDetailConcern

    def continue
      @errors = errors

      if @errors.present?
        render :new
      else
        redirect_to confirmation_provider_recruitment_cycle_courses_path(
          params[:provider_code],
          params[:recruitment_cycle_year],
          course_params,
        )
      end
    end

  private

    def errors; end

    def course_params
      if params.key?(:course)
        params.require(:course).permit(:start_date)
      else
        ActionController::Parameters.new({}).permit
      end
    end
  end
end
