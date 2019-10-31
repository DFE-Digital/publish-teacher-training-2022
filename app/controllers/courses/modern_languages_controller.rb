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
      updated_subject_list = strip_non_language_subjects
      updated_subject_list += selected_language_subjects
      if @course.update(subjects: updated_subject_list)
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

    def strip_non_language_subjects
      @course.subjects.reject { |s| available_languages_ids.include?(s.id) }
    end

    def selected_language_subjects
      language_ids = params.dig(:course, :language_ids)
      found_languages_ids = available_languages_ids & language_ids
      found_languages_ids.map { |id| Subject.new(id: id) }
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
