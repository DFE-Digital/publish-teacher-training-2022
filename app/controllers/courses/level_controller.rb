module Courses
  class LevelController < ApplicationController
    include CourseBasicDetailConcern

  private

    def error_keys
      [:level]
    end

    def current_step
      :level
    end
  end
end
