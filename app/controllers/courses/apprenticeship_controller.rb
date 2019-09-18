module Courses
  class ApprenticeshipController < ApplicationController
    include CourseBasicDetailConcern

    def continue
      @errors = errors

      if @errors.present?
        render :new
      else
        redirect_to next_step(current_step: :apprenticeship)
      end
    end

  private

    def errors; end
  end
end
