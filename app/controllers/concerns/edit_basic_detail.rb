module EditBasicDetail
  extend ActiveSupport::Concern

  included do
    decorates_assigned :course
    before_action :build_course
  end

  def edit; end

  def update
    @errors = errors
    return render :edit if @errors.any?

    # Age range 'other' override
    course = params.dig(:course)
    is_other = course.dig(:age_range_in_years) == "Other"

    if course.dig(:course_age_range_in_years_other_from).present? &&
        course.dig(:course_age_range_in_years_other_to).present? &&
        is_other
      params[:course][:age_range_in_years] = "#{course.dig(:course_age_range_in_years_other_from)}_to_#{course.dig(:course_age_range_in_years_other_to)}"
    elsif is_other
      params[:course][:age_range_in_years] = nil
    end

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

  def build_course
    @course = Course
      .where(recruitment_cycle_year: params[:recruitment_cycle_year])
      .where(provider_code: params[:provider_code])
      .find(params[:code])
      .first
  end
end
