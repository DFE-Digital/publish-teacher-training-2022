module Courses
  class StartDateController < ApplicationController
    include CourseBasicDetailConcern

    def continue
      @errors = errors

      if @errors.present?
        render :new
      else
        redirect_to next_step(current_step: :start_date)
      end
    end

  private

    def errors; end
  end
end
