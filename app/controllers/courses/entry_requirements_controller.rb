module Courses
  class EntryRequirementsController < ApplicationController
    include CourseBasicDetailConcern
    before_action :not_found_if_no_gcse_subjects_required, except: :continue

    def continue
      super
    end

  private

    def build_provider
      @provider = Provider
                    .includes(:sites)
                    .where(recruitment_cycle_year: params[:recruitment_cycle_year])
                    .find(params[:provider_code])
                    .first
    end

    def current_step
      :entry_requirements
    end

    def error_keys
      course.gcse_subjects_required.map(&:to_sym)
    end

    def errors
      course.gcse_subjects_required
        .reject { |subject| params.dig(:course, subject) }
        .map { |subject| [subject.to_sym, ["Pick an option for #{subject.titleize}"]] }
        .to_h
    end

    def not_found_if_no_gcse_subjects_required
      render template: "errors/not_found", status: :not_found if course.gcse_subjects_required.empty?
    end
  end
end
