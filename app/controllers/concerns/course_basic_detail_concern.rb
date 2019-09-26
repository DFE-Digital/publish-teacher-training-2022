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
      params.require(:course)
        .except(
          :day,
          :month,
          :year,
          :course_age_range_in_years_other_from,
          :course_age_range_in_years_other_to,
        )
        .permit(
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
          :level,
          :is_send,
          :program_type,
          :study_mode,
          :applications_open_from,
          :start_date,
          :age_range_in_years,
        )
    else
      ActionController::Parameters.new({}).permit(:course)
    end
  end

  def build_previous_course_creation_params
    @course_creation_params = course_params
  end

  def next_step(current_step:)
    next_step = NextCourseCreationStepService.new.execute(current_step: current_step)

    if course_creation_paths.key?(next_step)
      course_creation_paths[next_step]
    else
      raise "No path defined for next step: #{next_step}"
    end
  end

  def course_creation_paths
    {
      apprenticeship:  new_provider_recruitment_cycle_courses_apprenticeship_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params,
      ),
      # Currently the page isnt built - so skip
      location: new_provider_recruitment_cycle_courses_entry_requirements_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params,
      ),
      entry_requirements: new_provider_recruitment_cycle_courses_entry_requirements_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params,
      ),
      outcome: new_provider_recruitment_cycle_courses_outcome_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params,
      ),
      full_or_part_time: new_provider_recruitment_cycle_courses_study_mode_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params,
      ),
      applications_open: new_provider_recruitment_cycle_courses_applications_open_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params,
      ),
      start_date: new_provider_recruitment_cycle_courses_start_date_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params,
      ),
      age_range: new_provider_recruitment_cycle_courses_age_range_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params,
      ),
      confirmation: confirmation_provider_recruitment_cycle_courses_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course: course_params,
      ),
    }
  end
end
