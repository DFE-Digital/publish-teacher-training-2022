module Courses
  class ApprenticeshipController < ApplicationController
    include CourseBasicDetailConcern

  private

    def errors; end

    def course_params
      params.require(:course).permit(:program_type)
    end
  end
end
