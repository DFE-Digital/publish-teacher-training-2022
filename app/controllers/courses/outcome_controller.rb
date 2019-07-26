module Courses
  class OutcomeController < ApplicationController
    include EditBasicDetail

  private

    def errors
      params.dig(:course, :qualification) ? {} : { qualification: ["Pick an outcome"] }
    end

    def course_params
      params.require(:course).permit(:qualification)
    end
  end
end
