class CoursesController < ApplicationController
  include CourseFetcher

  decorates_assigned :course
  decorates_assigned :provider

  before_action :initialise_errors
  before_action :build_recruitment_cycle
  before_action :fetch_courses, only: %i[index about requirements fees salary]
  before_action :fetch_course, except: %i[index preview]
  before_action :build_course_for_preview, only: :preview
  before_action :filter_courses, only: %i[about requirements fees salary]
  before_action :fetch_course_to_copy_from, if: -> { params[:copy_from].present? }
  before_action :build_provider_from_provider_code, except: %i[index]

  def index; end

  def details; end

  def request_change; end

  def confirmation
    @course_creation_params = course_params

    build_new_course
  end

  def create
    build_course_from_params

    if @course.save
      flash[:success_with_body] = { title: "Your course has been created", body: "Add the rest of your details and publish the course, so that candidates can find and apply to it." }
      redirect_to(
        provider_recruitment_cycle_course_path(
          @course.provider_code,
          @course.recruitment_cycle_year,
          @course.course_code,
        ),
      )
    else
      @errors = @course.errors.messages

      @course_creation_params = course_params
      build_new_course

      render :confirmation
    end
  end

  def build_course_from_params
    @course = Course.new(
      course_params.to_h.merge(
        recruitment_cycle_year: @provider.recruitment_cycle_year,
        provider_code: @provider.provider_code,
      ),
    )

    @course.subjects = params.dig("course", "subjects_ids")&.map do |subject_id|
      Subject.new(id: subject_id)
    end

    @course.sites = params.dig("course", "sites_ids")&.map do |site_id|
      Site.new(id: site_id)
    end
  end

  def new
    return render_locations_messages unless @provider.sites&.any?

    redirect_to new_provider_recruitment_cycle_courses_level_path(params[:provider_code], @recruitment_cycle.year)
  end

  def update
    massage_update_course_params

    if @course.update(course_params)
      flash[:success] = I18n.t("success.saved")
      redirect_to(
        provider_recruitment_cycle_course_path(
          @course.provider_code,
          @course.recruitment_cycle_year,
          @course.course_code,
        ),
      )
    else
      @errors = @course.errors.messages

      render course_params["page"].to_sym
    end
  end

  def show
    @errors = flash[:error_summary]
    flash.delete(:error_summary)
  end

  def about
    show_deep_linked_errors(%i[about_course interview_process how_school_placements_work])

    if params[:copy_from].present?
      @copied_fields = Courses::Copy.get_present_fields_in_source_course(Courses::Copy::ABOUT_FIELDS, @source_course, @course)
    end
  end

  def requirements
    show_deep_linked_errors(%i[required_qualifications personal_qualities other_requirements])

    if params[:copy_from].present?
      @copied_fields = Courses::Copy.get_present_fields_in_source_course(get_requirement_fields, @source_course, @course)
    end
  end

  def fees
    show_deep_linked_errors(%i[course_length fee_uk_eu fee_international fee_details financial_support])

    if params[:copy_from].present?
      @copied_fields = Courses::Copy.get_present_fields_in_source_course(Courses::Copy::FEES_FIELDS, @source_course, @course)
    end
  end

  def salary
    show_deep_linked_errors(%i[course_length salary_details])

    if params[:copy_from].present?
      @copied_fields = Courses::Copy.get_present_fields_in_source_course(Courses::Copy::SALARY_FIELDS, @source_course, @course)
    end
  end

  def withdraw; end

  def withdraw_course
    if request.post?
      if course_withdrawn?
        flash[:error] = { id: "withdraw-error", message: "#{@course.course_code} has already been withdrawn" }
        redirect_to provider_recruitment_cycle_courses_path(@provider.provider_code, @course.recruitment_cycle_year, @course.course_code)
      elsif params[:course][:confirm_course_code] == @course.course_code
        @course.withdraw
        redirect_to provider_recruitment_cycle_courses_path(@provider.provider_code, @provider.recruitment_cycle_year)
        flash[:success] = "#{@course.name} (#{@course.course_code}) has been withdrawn"
      else
        flash[:error] = { id: "withdraw-error", message: "Enter the course code (#{@course.course_code}) to withdraw this course" }
        redirect_to withdraw_provider_recruitment_cycle_course_path(@provider.provider_code, @course.recruitment_cycle_year, @course.course_code)
      end
    else
      render template: "courses/withdraw"
    end
  end

  def delete; end

  def preview; end

  def destroy
    if params[:course][:confirm_course_code] == @course.course_code
      @course.destroy
      redirect_to provider_recruitment_cycle_courses_path(@provider.provider_code, @provider.recruitment_cycle_year)
      flash[:success] = "#{@course.name} (#{@course.course_code}) has been deleted"
    else
      flash[:error] = { id: "delete-error", message: "Enter the course code (#{@course.course_code}) to delete this course" }
      redirect_to delete_provider_recruitment_cycle_course_path(@provider.provider_code, @course.recruitment_cycle_year, @course.course_code)
    end
  end

  def publish
    if @course.publish
      flash[:success] = "Your course has been published."
      redirect_to provider_recruitment_cycle_course_path(@provider.provider_code, @course.recruitment_cycle_year, @course.course_code)
    else
      @errors = @course.errors.messages
      fetch_course
      render :show
    end
  end

private

  def course_withdrawn?
    @course.content_status == "withdrawn"
  end

  def build_provider_from_provider_code
    @provider = Provider
      .includes(:sites)
      .where(recruitment_cycle_year: @recruitment_cycle.year)
      .find(params[:provider_code])
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
        :level,
        :is_send,
        :program_type,
        :study_mode,
        :applications_open_from,
        :start_date,
        :funding_type,
        :age_range_in_years,
        :accredited_body_code,
        subjects_ids: [],
        sites_ids: [],
      )
    else
      ActionController::Parameters.new({}).permit(:course)
    end
  end

  def build_new_course
    @course = Course.build_new(
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      provider_code: @provider.provider_code,
      course: course_params.to_unsafe_hash,
    )
  end

  def build_course_for_preview
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle,
    )

    @course = Course
      .includes(:subjects)
      .includes(:sites)
      .includes(site_statuses: [:site])
      .includes(provider: [:sites])
      .includes(:accrediting_provider)
      .where(recruitment_cycle_year: cycle_year)
      .where(provider_code: params[:provider_code])
      .find(params[:code])
      .first
  rescue JsonApiClient::Errors::NotFound
    render file: "errors/not_found", status: :not_found
  end

  def filter_courses
    @courses_by_accrediting_provider = @courses_by_accrediting_provider.reject { |c| c == course.id }
    @self_accredited_courses = @self_accredited_courses&.reject { |c| c.id == course.id }
  end

  def initialise_errors
    @errors = {}
  end

  def show_deep_linked_errors(attributes)
    return if params[:display_errors].blank?

    @course.publishable?
    @errors = @course.errors.messages.select { |key| attributes.include? key }
  end

  def build_recruitment_cycle
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle,
    )

    @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
  end

  def massage_update_course_params
    # Course length should be saved as `course_length` so if "other" is selected then pass that text value into `course_length`
    if params[:course][:course_length_other_length].present? && params[:course][:course_length] == "Other"
      params[:course][:course_length] = params[:course][:course_length_other_length]
    end
    params[:course].delete(:course_length_other_length)

    # A user has been struggling to input a number in the course fees box because
    # our validations do not allow commas to be added. eg 9,000 is not accepted.
    # By stripping commas out the backend will not reject such input.
    params[:course][:fee_uk_eu].gsub!(",", "") if params[:course][:fee_uk_eu].present?
    params[:course][:fee_international].gsub!(",", "") if params[:course][:fee_international].present?
  end

  def get_requirement_fields
    if @course.recruitment_cycle_year.to_i >= Provider::CHANGES_INTRODUCED_IN_2022_CYCLE
      Courses::Copy::POST_2022_CYCLE_REQUIREMENTS_FIELDS
    else
      Courses::Copy::PRE_2022_CYCLE_REQUIREMENTS_FIELDS
    end
  end

  def render_locations_messages
    flash[:error] = { id: "locations-error", message: "You need to create at least one location before creating a course" }

    redirect_to new_provider_recruitment_cycle_site_path(@provider.provider_code, @provider.recruitment_cycle_year)
  end
end
