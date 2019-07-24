module Courses
  class EntryRequirementsController < ApplicationController
    decorates_assigned :course
    before_action :build_course
    before_action :not_found_if_no_gcse_subjects_required

    def edit; end

    def update
      @errors = missing_subject_errors
      return render :edit if @errors.any?

      if @course.update(course_params)
        flash[:success] = 'Your changes have been saved'
        redirect_to(
          details_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code
          )
        )
      else
        @errors = @course.errors.messages
        render :edit
      end
    end

  private

    def missing_subject_errors
      course.gcse_subjects_required
        .reject { |subject| params.dig(:course, subject) }
        .map { |subject| [subject.to_sym, ["Pick an option for #{subject.titleize}"]] }
        .to_h
    end

    def course_params
      params.require(:course).permit(
        :maths,
        :english,
        :science
      )
    end

    def build_course
      @course = Course
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: params[:provider_code])
        .find(params[:code])
        .first
    end

    def not_found_if_no_gcse_subjects_required
      render file: 'errors/not_found', status: :not_found if course.gcse_subjects_required.empty?
    end
  end
end
