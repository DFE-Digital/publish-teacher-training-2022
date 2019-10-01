module Courses
  class StartDateController < ApplicationController
    include CourseBasicDetailConcern

  private

    def current_step
      :start_date
    end

    def errors; end
  end
end
