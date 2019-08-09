module Courses
  class SendController < ApplicationController
    include EditBasicDetail

    def edit; end

  private

    def errors; end

    def course_params
      params.require(:course).permit(:is_send)
    end
  end
end
