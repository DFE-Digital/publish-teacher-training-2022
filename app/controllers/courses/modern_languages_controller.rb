module Courses
  class ModernLanguagesController < ApplicationController
    decorates_assigned :course
    before_action :build_course, only: %i[edit update]
    before_action :build_course_params, only: [:continue]
    include CourseBasicDetailConcern

    def new
      return unless @course.meta[:edit_options][:modern_languages].nil?

      redirect_to next_step
    end

    def continue
      super
    end

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

    def back
      if @course.meta[:edit_options][:modern_languages].nil?
        redirect_to @back_link_path
      else
        redirect_to new_provider_recruitment_cycle_courses_modern_languages_path(path_params)
      end
    end

    def current_step
      :modern_languages
    end

  private

    def error_keys
      [:modern_languages_subjects]
    end

    def strip_non_language_subjects
      @course.subjects.reject { |s| available_languages_ids.include?(s.id) }
    end

    def selected_language_subjects
      language_ids = params.dig(:course, :language_ids)
      if language_ids.present?
        found_languages_ids = available_languages_ids & language_ids
        found_languages_ids.map { |id| Subject.new(id: id) }
      else
        []
      end
    end

    def available_languages_ids
      @course.meta[:edit_options][:modern_languages].map do |language|
        language["id"]
      end
    end

    def build_course
      @course = Course
                  .includes(:subjects, :site_statuses)
                  .where(recruitment_cycle_year: params[:recruitment_cycle_year])
                  .where(provider_code: params[:provider_code])
                  .find(params[:code])
                  .first
    end

    def build_course_params
      first_level_subject = params[:course][:subjects_ids].first
      params[:course][:subjects_ids] = [first_level_subject, params[:course][:language_ids]].flatten if params[:course][:language_ids]
      params[:course].delete :language_ids
    end
  end
end
