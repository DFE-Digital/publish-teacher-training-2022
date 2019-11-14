module Courses
  class EntryRequirementsController < ApplicationController
    include CourseBasicDetailConcern
    before_action :build_back_link, only: :new

    before_action :not_found_if_no_gcse_subjects_required, except: :continue

  private

    def build_back_link
      @back_link_path = if @provider.accredited_body?
                          if @provider.sites.count > 1
                            new_provider_recruitment_cycle_courses_locations_path(course: @course_creation_params)
                          else
                            new_provider_recruitment_cycle_courses_study_mode_path(course: @course_creation_params)
                          end
                        else
                          new_provider_recruitment_cycle_courses_accredited_body_path(course: @course_creation_params)
                        end
    end

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
