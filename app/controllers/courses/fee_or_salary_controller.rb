module Courses
  class FeeOrSalaryController < ApplicationController
    include CourseBasicDetailConcern

  private

    def current_step
      :fee_or_salary
    end

    def error_keys
      [:funding_type]
    end
  end
end
