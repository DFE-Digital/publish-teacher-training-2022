module Courses
  class SubjectsController < ApplicationController
    decorates_assigned :course
    before_action :build_course, only: %i[edit update]
    before_action :build_course_params, only: [:continue]
    include CourseBasicDetailConcern

    def update
      if subjects_have_not_been_changed?
        flash[:success] = "Your subject hasn't been changed"
        redirect_to(
          details_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          ),
        )
      elsif @course.update(subjects: selected_subjects)
        flash[:success] = "Your changes have been saved"
        redirect_to(
          modern_languages_provider_recruitment_cycle_course_path(
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

    def subjects_have_not_been_changed?
      subjects_match?(selected_subjects, existing_non_language_subjects)
    end

    def subjects_match?(subject_array_a, subject_array_b)
      subject_array_a.zip(subject_array_b).all? do |subject_a, subject_b|
        subject_a.present? && subject_b.present? && subject_a.id == subject_b.id
      end
    end

    def existing_non_language_subjects
      @course.subjects.select do |course_subject|
        is_a_non_language_subject?(course_subject)
      end
    end

    def selected_subjects
      master_subject_id = params.dig(:course, :master_subject_id)
      master_subject_hash = @course.meta[:edit_options][:subjects].find do |subject|
        subject[:id] == master_subject_id
      end
      [Subject.new(master_subject_hash.to_h)]
    end

    def is_a_non_language_subject?(subject_to_find)
      @course.meta[:edit_options][:subjects].any? do |subject|
        subject[:id] == subject_to_find.id
      end
    end

    def current_step
      :subjects
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
      params[:course][:subjects_ids] = [params[:course][:master_subject_id]]
      params[:course].delete :master_subject_id
    end
  end
end
