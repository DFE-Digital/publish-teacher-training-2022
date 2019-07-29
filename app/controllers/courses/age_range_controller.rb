module Courses
  class AgeRangeController < ApplicationController
    include EditBasicDetail

  private

    def errors
      params.dig(:course, :age_range_in_years) ? {} : { age_range_in_years: ["Pick an age range"] }
    end

    def course_params
      params.require(:course).permit(:age_range_in_years)
    end
  end
end
