module Courses
  class OutcomeController < ApplicationController
    include CourseBasicDetailConcern

    def continue
      @errors = errors

      if @errors.present?
        render :new
      else
        redirect_to next_step(current_step: :outcome)
      end
    end

  private

    def errors
      params.dig(:course, :qualification) ? {} : { qualification: ["Pick an outcome"] }
    end
  end
end
