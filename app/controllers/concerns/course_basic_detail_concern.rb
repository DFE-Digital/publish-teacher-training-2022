module CourseBasicDetailConcern
  extend ActiveSupport::Concern

  included do
    decorates_assigned :course
    before_action :build_provider, :build_new_course, only: %i[new continue]
    before_action :get_previous_course_creation_params, only: %i[new continue]
    before_action :build_course, only: %i[edit update]
  end

  def new; end

  def edit; end

  def update
    @errors = errors
    return render :edit if @errors.present?

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

  def build_new_course
    @course = Course.fetch_new(
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      provider_code: @provider.provider_code
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

  def get_previous_course_creation_params
    return unless params.has_key?(:course)

    @course_creation_params = params.require(:course).permit(
      :qualification, :maths, :english, :science
    )
  end

  def next_step(current_step:, course_params:)
    if current_step == :outcome
      new_provider_recruitment_cycle_courses_entry_requirements_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params
      )
    elsif current_step == :entry_requirements
      new_provider_recruitment_cycle_courses_outcome_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params.merge(@course_creation_params)
      )
    end
  end
end
