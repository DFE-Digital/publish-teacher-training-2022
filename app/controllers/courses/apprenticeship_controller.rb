module Courses
  class ApprenticeshipController < ApplicationController
    include CourseBasicDetailConcern

  private

    def current_step
      :apprenticeship
    end

    def error_keys
      [:funding_type]
    end
  end
end
