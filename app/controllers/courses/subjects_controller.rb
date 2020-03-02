module Courses
  class SubjectsController < ApplicationController
    decorates_assigned :course
    before_action :build_course, only: %i[edit update]
    before_action :build_course_params, only: [:continue]
    include CourseBasicDetailConcern

    def edit; end

    def continue
      super
    end

    def update
      if has_modern_languages_subject?
        redirect_to(
          modern_languages_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
            course: { subjects_ids: selected_subject_ids },
          ),
        )
      elsif @course.update(subjects: selected_subjects)
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

    def has_modern_languages_subject?
      selected_subjects.any? do |s|
        s.id.to_s == modern_languages_subject.id.to_s
      end
    end

    def modern_languages_subject
      return @modern_languages_subject if @modern_languages_subject

      hash = @course.meta[:edit_options][:modern_languages_subject]
      @modern_languages_subject = Subject.new(hash)
    end

    def selected_subject_ids
      params
        .dig(:course)
        .slice(:master_subject_id, :subordinate_subject_id)
        .to_unsafe_h
        .values
        .select(&:present?)
    end

    def selected_subjects
      selected_subject_ids.map do |subject_id|
        subject_hash = find_subject(subject_id)
        Subject.new(subject_hash.to_h)
      end
    end

    def find_subject(subject_id)
      @course.meta[:edit_options][:subjects].find do |subject|
        subject[:id] == subject_id
      end
    end

    def current_step
      :subjects
    end

    def error_keys
      [:subjects]
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
      params[:course][:subjects_ids] = []
      params[:course][:subjects_ids] << params[:course][:master_subject_id]
      params[:course][:subjects_ids] << params[:course][:subordinate_subject_id] if params[:course][:subordinate_subject_id].present?
      params[:course].delete(:master_subject_id)
      params[:course].delete(:subordinate_subject_id)
    end
  end
end
