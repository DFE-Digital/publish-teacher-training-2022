module Courses
  class FeeOrSalaryController < ApplicationController
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
  end
end
