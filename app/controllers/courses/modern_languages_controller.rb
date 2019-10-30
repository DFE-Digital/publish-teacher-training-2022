module Courses
  class ModernLanguagesController < ApplicationController
    include CourseBasicDetailConcern
    decorates_assigned :course
    before_action :build_course, only: %i[edit update]

    def edit
      return unless @course.meta[:edit_options][:modern_languages].nil?

      redirect_to(
        details_provider_recruitment_cycle_course_path(
          @course.provider_code,
          @course.recruitment_cycle_year,
          @course.course_code,
        ),
      )
    end

    def update
      if @course.update(subjects: old_non_language_subjects + new_language_subjects)
        flash[:success] = "Your changes have been saved"
        redirect_to(
          details_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          ),
        )
      else
        @errors = @course.errors.messages
        render :edit
      end
    end

  private

    def new_language_subjects
      language_ids = params.dig(:course, :language_ids)
      found_languages_ids = available_languages_ids & language_ids

      found_languages_ids.map do |language_id|
        Subject.new(id: language_id)
      end
    end

    def old_non_language_subjects
      @course.subjects.reject do |subject|
        available_languages_ids.include?(subject.id)
      end
    end

    def available_languages_ids
      @course.meta[:edit_options][:modern_languages].map do |language|
        language["id"]
      end
    end

    def errors; end

    def build_course
      @course = Course
                  .includes(:subjects, :site_statuses)
                  .where(recruitment_cycle_year: params[:recruitment_cycle_year])
                  .where(provider_code: params[:provider_code])
                  .find(params[:code])
                  .first
    end
  end
end
