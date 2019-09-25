module Courses
  class StudyModeController < ApplicationController
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

    def update
      if params[:course][:study_mode] == "full_time_or_part_time"
        redirect_to request_change_provider_recruitment_cycle_course_path(params[:provider_code], params[:recruitment_cycle_year], params[:code])
      else
        super
      end
    end

  private

    def errors
      params.dig(:course, :study_mode) ? {} : { study_mode: ["Pick full time, part time or full time and part time"] }
    end

    def course_params
      if params.key?(:course)
        params.require(:course).permit(:study_mode)
      else
        ActionController::Parameters.new({}).permit
      end
    end
  end
end
