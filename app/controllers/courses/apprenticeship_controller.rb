module Courses
  class ApprenticeshipController < ApplicationController
    include CourseBasicDetailConcern

  private

    def current_step
      :apprenticeship
    end
  end
end
