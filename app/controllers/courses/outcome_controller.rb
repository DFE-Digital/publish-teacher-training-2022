module Courses
  class OutcomeController < ApplicationController
    include CourseBasicDetailConcern

  private

    def current_step
      :outcome
    end

    def errors
      params.dig(:course, :qualification) ? {} : { qualification: ["Pick an outcome"] }
    end
  end
end
