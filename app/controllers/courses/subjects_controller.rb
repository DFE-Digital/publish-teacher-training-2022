module Courses
  class SubjectsController < ApplicationController
    decorates_assigned :course
    before_action :build_course, only: %i[edit update]
    before_action :build_course_params, only: [:continue]
    include CourseBasicDetailConcern

    def update
      master_subject_id = params.dig(:course, :master_subject_id)
      master_subject_hash = @course.meta[:edit_options][:subjects].find do |subject|
        subject[:id] == master_subject_id
      end
      master_subject = Subject.new(master_subject_hash.to_h)

      if @course.update(subjects: [master_subject])
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

    def current_step
      :subjects
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

    def build_course_params
      params[:course][:subjects_ids] = [params[:course][:master_subject_id]]
      params[:course].delete :master_subject_id
    end
  end
end
