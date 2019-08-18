module CourseBasicDetailConcern
  extend ActiveSupport::Concern

  included do
    decorates_assigned :course
    before_action :build_provider, only: :new
    before_action :build_course, only: %i[edit update]
  end

  def new
    # Using .find(:new) here is a little bit hacky, but this is the only way I
    # could find to construct the URL with `.../courses/new` at the end, and at
    # the end of the day jsonapi defines ids as being strings so it's in no way
    # invalid. If we can find a way to use custom enpoints or other to improve
    # this we should.
    @course = Course
                .where(recruitment_cycle_year: params[:recruitment_cycle_year],
                       provider_code: params[:provider_code])
                .find(:new)
                .first
    nil
  end

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
end
