module Courses
  class LevelController < ApplicationController
    include CourseBasicDetailConcern

  private

    def errors; end

    def course_params
      params.require(:course).permit(:level)
    end
  end
end
