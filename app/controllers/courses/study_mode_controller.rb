module Courses
  class StudyModeController < ApplicationController
    include CourseBasicDetailConcern
    before_action :build_back_link, only: :new

    def update
      if params[:course][:study_mode] == "full_time_or_part_time"
        redirect_to request_change_provider_recruitment_cycle_course_path(params[:provider_code], params[:recruitment_cycle_year], params[:code])
      else
        super
      end
    end

  private

    def build_back_link
      @back_link_path = if @provider.accredited_body?
                          new_provider_recruitment_cycle_courses_apprenticeship_path(course: @course_creation_params)
                        else
                          new_provider_recruitment_cycle_courses_fee_or_salary_path(course: @course_creation_params)
                        end
    end

    def current_step
      :full_or_part_time
    end

    def errors
      params.dig(:course, :study_mode) ? {} : { study_mode: ["Pick full time, part time or full time and part time"] }
    end
  end
end
