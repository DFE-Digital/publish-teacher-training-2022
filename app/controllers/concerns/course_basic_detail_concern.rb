module CourseBasicDetailConcern
  extend ActiveSupport::Concern

  included do
    decorates_assigned :course
    before_action :build_provider, :build_new_course, only: %i[new continue]
    before_action :build_previous_course_creation_params, only: %i[new continue]
    before_action :build_course, only: %i[edit update]
  end

  def new; end

  def edit; end

  def update
    @errors = errors
    return render :edit if @errors.present?

    if @course.update(course_params)
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

  def build_new_course
    @course = Course.build_new(
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      provider_code: @provider.provider_code,
      course: course_params.to_unsafe_hash,
    )
  end

  def build_provider
    @provider = Provider
                  .where(recruitment_cycle_year: params[:recruitment_cycle_year])
                  .find(params[:provider_code])
                  .first
  end

  def build_course
    @course = Course
      .where(recruitment_cycle_year: params[:recruitment_cycle_year])
      .where(provider_code: params[:provider_code])
      .find(params[:code])
      .first
  end

  def course_params
    if params.key? :course
      params.require(:course).permit(
        :page,
        :about_course,
        :course_length,
        :course_length_other_length,
        :fee_details,
        :fee_international,
        :fee_uk_eu,
        :financial_support,
        :how_school_placements_work,
        :interview_process,
        :other_requirements,
        :personal_qualities,
        :salary_details,
        :required_qualifications,
        :qualification, # qualification is actually "outcome"
        :maths,
        :english,
        :science,
        :funding_type,
      )
    else
      ActionController::Parameters.new({}).permit(:course)
    end
  end

  def build_previous_course_creation_params
    @course_creation_params = course_params
  end

  def next_step(current_step:)
    if current_step == :outcome
      new_provider_recruitment_cycle_courses_entry_requirements_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params,
      )
    elsif current_step == :entry_requirements
      new_provider_recruitment_cycle_courses_outcome_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params,
      )
    end
  end
end
