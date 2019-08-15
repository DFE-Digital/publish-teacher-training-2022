module Courses
  class SendController < ApplicationController
    include CourseBasicDetailConcern

  private

    def errors; end

    def course_params
      params.require(:course).permit(:is_send)
    end
  end
end
