module Courses
  class SendController < ApplicationController
    include CourseBasicDetailConcern

  private

    def errors; end
  end
end
