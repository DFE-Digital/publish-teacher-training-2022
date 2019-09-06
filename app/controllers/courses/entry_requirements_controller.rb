module Courses
  class EntryRequirementsController < ApplicationController
    include CourseBasicDetailConcern

    before_action :not_found_if_no_gcse_subjects_required, except: :continue

    def continue
      redirect_to next_step(current_step: :entry_requirements)
    end

  private

    def errors
      course.gcse_subjects_required
        .reject { |subject| params.dig(:course, subject) }
        .map { |subject| [subject.to_sym, ["Pick an option for #{subject.titleize}"]] }
        .to_h
    end

    def not_found_if_no_gcse_subjects_required
      render file: 'errors/not_found', status: :not_found if course.gcse_subjects_required.empty?
    end
  end
end
