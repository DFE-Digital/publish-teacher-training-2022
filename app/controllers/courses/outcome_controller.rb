module Courses
  class OutcomeController < ApplicationController
    include CourseBasicDetailConcern

    def continue
      @errors = errors

      if @errors.present?
        render :new
      else
        redirect_to next_step(
          current_step: :outcome,
          course_params: course_params.merge(@course_creation_params)
        )
      end
    end

  private

    def errors
      params.dig(:course, :qualification) ? {} : { qualification: ["Pick an outcome"] }
    end

    def course_params
      params.require(:course).permit(:qualification)
    end
  end
end
