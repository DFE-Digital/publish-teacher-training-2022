module Courses
  class ApplicationsOpenController < ApplicationController
    before_action :build_recruitment_cycle
    include EditBasicDetail

  private

    def errors; end

    def actual_params
      params.require(:course).permit(
        :applications_open_from,
        :day,
        :month,
        :year
      )
    end

    def course_params
      applications_open_from =
        if actual_params['applications_open_from'] == 'other'
          "#{actual_params['year']}-#{actual_params['month']}-#{actual_params['day']}"
        else
          actual_params['applications_open_from']
        end

      {
        applications_open_from: applications_open_from
      }
    end

    def build_recruitment_cycle
      cycle_year = params.fetch(
        :recruitment_cycle_year,
        Settings.current_cycle
      )

      @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
    end
  end
end
