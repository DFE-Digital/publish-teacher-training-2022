module Courses
  class FeeOrSalaryController < ApplicationController
    include CourseBasicDetailConcern

  private

    def current_step
      :fee_or_salary
    end
  end
end
