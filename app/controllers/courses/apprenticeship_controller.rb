module Courses
  class ApprenticeshipController < ApplicationController
    include CourseBasicDetailConcern

    def continue
      redirect_to confirmation_provider_recruitment_cycle_courses_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course_params
      )
    end

  private

    def errors; end

    def course_params
      params.require(:course).permit(:program_type)
    end
  end
end
