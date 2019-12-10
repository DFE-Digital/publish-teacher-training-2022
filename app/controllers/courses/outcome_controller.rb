module Courses
  class OutcomeController < ApplicationController
    include CourseBasicDetailConcern
    before_action :order_edit_options, only: %i[edit new]

  private

    def order_edit_options
      ensure_edit_options_are_equal
      @course.meta["edit_options"]["qualifications"] = if @course.level == "further_education"
                                                         non_qts_qualifications
                                                       else
                                                         qts_qualifications
                                                       end
    end

    def current_step
      :outcome
    end

    def ensure_edit_options_are_equal
      qualification_options = @course.meta["edit_options"]["qualifications"]

      if @course.level == "further_education"
        if qualification_options.sort != non_qts_qualifications.sort
          raise "Non QTS qualification options do not match"
        end
      elsif qualification_options.sort != qts_qualifications.sort
        raise "QTS qualification options do not match"
      end
    end

    def qts_qualifications
      %w[pgce_with_qts qts pgde_with_qts]
    end

    def non_qts_qualifications
      %w[pgce pgde]
    end

    def errors
      params.dig(:course, :qualification) ? {} : { qualification: ["Pick an outcome"] }
    end
  end
end
