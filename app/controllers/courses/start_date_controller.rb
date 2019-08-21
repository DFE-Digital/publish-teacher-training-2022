module Courses
  class StartDateController < ApplicationController
    include CourseBasicDetailConcern

  private

    def errors; end

    def course_params
      params.require(:course).permit(:start_date)
    end
  end
end
