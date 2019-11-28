module CourseBasicDetailConcern
  extend ActiveSupport::Concern

  included do
    decorates_assigned :course
    before_action :build_provider, :build_new_course, only: %i[new continue]
    before_action :build_previous_course_creation_params, only: %i[new continue]
    before_action :build_meta_course_creation_params, only: %i[new continue]
    before_action :build_back_link, only: %i[new continue]
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

  def continue
    @errors = errors

    if @errors.any?
      render :new
    elsif params[:goto_confirmation].present?
      redirect_to confirmation_provider_recruitment_cycle_courses_path(path_params)
    else
      redirect_to next_step
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

  def errors
    @course.errors.messages.select { |key, _message| error_keys.include?(key) }
  end

  def error_keys
    []
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
          :goto_confirmation,
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
          :master_subject_id,
          :subordinate_subject_id,
          :funding_type,
          :accrediting_provider_code,
          sites_ids: [],
          subjects_ids: [],
        )
    else
      ActionController::Parameters.new({}).permit(:course)
    end
  end

  def build_previous_course_creation_params
    @course_creation_params = course_params
  end

  def build_meta_course_creation_params
    @meta_course_creation_params = params.slice(:goto_confirmation)
  end

  def next_step
    next_step = NextCourseCreationStepService.new.execute(current_step: current_step, current_provider: @provider)
    next_page = course_creation_path_for(next_step)

    if next_page.nil?
      raise "No path defined for next step: #{next_step}"
    end

    next_page
  end

  def path_params
    { course: course_params }
  end

  def build_back_link
    previous_step = PreviousCourseCreationStepService.new.execute(current_step: current_step, current_provider: @provider)
    previous_path = course_creation_path_for(previous_step)

    if previous_path.nil?
      raise "No path defined for next step: #{previous_step}"
    end

    @back_link_path = previous_path
  end

  def course_creation_path_for(page)
    case page
    when :courses_list
      provider_recruitment_cycle_courses_path(@provider.provider_code, @provider.recruitment_cycle_year)
    when :level
      new_provider_recruitment_cycle_courses_level_path(path_params)
    when :apprenticeship
      new_provider_recruitment_cycle_courses_apprenticeship_path(path_params)
    when :location
      new_provider_recruitment_cycle_courses_locations_path(path_params)
    when :entry_requirements
      new_provider_recruitment_cycle_courses_entry_requirements_path(path_params)
    when :outcome
      new_provider_recruitment_cycle_courses_outcome_path(path_params)
    when :full_or_part_time
      new_provider_recruitment_cycle_courses_study_mode_path(path_params)
    when :applications_open
      new_provider_recruitment_cycle_courses_applications_open_path(path_params)
    when :accredited_body
      new_provider_recruitment_cycle_courses_accredited_body_path(path_params)
    when :start_date
      new_provider_recruitment_cycle_courses_start_date_path(path_params)
    when :age_range
      new_provider_recruitment_cycle_courses_age_range_path(path_params)
    when :subjects
      new_provider_recruitment_cycle_courses_subjects_path(path_params)
    when :fee_or_salary
      new_provider_recruitment_cycle_courses_fee_or_salary_path(path_params)
    when :confirmation
      confirmation_provider_recruitment_cycle_courses_path(path_params)
    end
  end
end
