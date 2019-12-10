module Courses
  class OutcomeController < ApplicationController
    include CourseBasicDetailConcern
    before_action :order_edit_options, only: %i[edit new]

  private

    def order_edit_options
      @course.meta["edit_options"]["qualifications"] = if @course.level == "further_education"
                                                         %w[pgce pgde]
                                                       else
                                                         %w[pgce_with_qts qts pgde_with_qts]
                                                       end
    end

    def current_step
      :outcome
    end

    def errors
      params.dig(:course, :qualification) ? {} : { qualification: ["Pick an outcome"] }
    end
  end
end
