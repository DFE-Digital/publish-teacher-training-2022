module Courses
  class StudyModeController < ApplicationController
    include EditBasicDetail

    def update
      if params[:course][:study_mode] == 'full_time_or_part_time'
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
      params.require(:course).permit(:study_mode)
    end
  end
end
