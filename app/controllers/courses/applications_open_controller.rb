module Courses
  class ApplicationsOpenController < ApplicationController
    before_action :build_recruitment_cycle
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

    def actual_params
      params.require(:course).permit(
        :applications_open_from,
        :day,
        :month,
        :year,
      )
    end

    def course_params
      if params.key?(:course)
        applications_open_from =
          if actual_params["applications_open_from"] == "other"
            "#{actual_params['year']}-#{actual_params['month']}-#{actual_params['day']}"
          else
            actual_params["applications_open_from"]
          end
        ActionController::Parameters.new(applications_open_from: applications_open_from).permit(:applications_open_from)
      else
        ActionController::Parameters.new({}).permit
      end
    end

    def build_recruitment_cycle
      cycle_year = params.fetch(
        :recruitment_cycle_year,
        Settings.current_cycle,
      )

      @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
    end
  end
end
