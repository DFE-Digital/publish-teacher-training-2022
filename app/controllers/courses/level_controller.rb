module Courses
  class LevelController < ApplicationController
    include CourseBasicDetailConcern

  private

    def errors; end

    def current_step
      :level
    end
  end
end
