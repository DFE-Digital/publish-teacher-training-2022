module Courses
  class StudyModeController < ApplicationController
    include EditBasicDetail

  private

    def errors
      params.dig(:course, :study_mode) ? {} : { study_mode: ["Pick full time, part time or full time and part time"] }
    end

    def course_params
      params.require(:course).permit(:study_mode)
    end
  end
end
