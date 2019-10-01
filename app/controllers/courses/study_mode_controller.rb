module Courses
  class StudyModeController < ApplicationController
    include CourseBasicDetailConcern

    def update
      if params[:course][:study_mode] == "full_time_or_part_time"
        redirect_to request_change_provider_recruitment_cycle_course_path(params[:provider_code], params[:recruitment_cycle_year], params[:code])
      else
        super
      end
    end

  private

    def current_step
      :full_or_part_time
    end

    def errors
      params.dig(:course, :study_mode) ? {} : { study_mode: ["Pick full time, part time or full time and part time"] }
    end
  end
end
