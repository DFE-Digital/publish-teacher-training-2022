class CoursesController < ApplicationController
  decorates_assigned :course
  before_action :build_courses, only: %i[index about requirements fees salary]
  before_action :build_course, except: :index
  before_action :build_provider, except: :index
  before_action :filter_courses, only: %i[about requirements fees salary]
  before_action :build_copy_course, if: -> { params[:copy_from].present? }

  def index; end

  def show; end

  def update
    if @course.save
      flash[:success] = 'Your changes have been saved'
      redirect_to(
        description_provider_course_path(
          @provider.provider_code,
          @course.course_code
        )
      )
    end
  end

  def description
    @published = flash[:success]
    flash.delete(:success)

    @errors = flash[:error_summary]
    flash.delete(:error_summary)
  end

  def about
    if params[:copy_from].present?
      @copied_fields = [
        ['About the course', 'about_course'],
        ['Interview process', 'interview_process'],
        ['How school placements work', 'how_school_placements_work']
      ].keep_if { |_name, field| copy_field_if_present_in_source_course(field) }
    end
  end

  def requirements
    if params[:copy_from].present?
      @copied_fields = [
        ['Qualifications needed', 'required_qualifications'],
        ['Personal qualities', 'personal_qualities'],
        ['Other requirements', 'other_requirements']
      ].keep_if { |_name, field| copy_field_if_present_in_source_course(field) }
    end
  end

  def fees
    if params[:copy_from].present?
      @copied_fields = [
        ['Course length', 'course_length'],
        ['Fee for UK and EU students', 'fee_uk_eu'],
        ['Fee for international students', 'fee_international'],
        ['Fee details', 'fee_details'],
        ['Financial support', 'financial_support']
      ].keep_if { |_name, field| copy_field_if_present_in_source_course(field) }
    end
  end

  def salary
    if params[:copy_from].present?
      @copied_fields = [
        ['Course length', 'course_length'],
        ['Salary details', 'salary_details']
      ].keep_if { |_name, field| copy_field_if_present_in_source_course(field) }
    end
  end

  def withdraw; end

  def delete; end

  def preview; end

  def publish
    errors = @course.publish(provider_code: @provider.provider_code).errors
    if errors.present?
      flash[:error_summary] = errors.map { |error|
        [
          error[:title].last(error[:title].length - 'Invalid latest_enrichment__'.length),
          error[:detail]
        ]
      }.to_h
    else
      flash[:success] = "Your course has been published. The link for this course is: #{Settings.search_ui.base_url}/course/#{@provider.provider_code}/#{@course.course_code}"
    end

    redirect_to description_provider_course_path(@provider.provider_code, @course.course_code)
  end

private

  def build_course
    @provider_code = params[:provider_code]
    @course = Course
      .includes(:sites)
      .includes(provider: [:sites])
      .includes(:accrediting_provider)
      .where(provider_code: @provider_code)
      .find(params[:code])
      .first
  rescue JsonApiClient::Errors::NotFound
    render file: 'errors/not_found', status: :not_found
  end

  def build_provider
    @provider = @course.provider
  end

  def build_courses
    @provider = Provider
      .includes(courses: [:accrediting_provider])
      .find(params[:provider_code])
      .first

    # rubocop:disable Style/MultilineBlockChain
    @courses_by_accrediting_provider = @provider
      .courses
      .group_by { |course|
        # HOTFIX: A courses API response no included hash seems to cause issues with the
        # .accrediting_provider relationship lookup. To be investigated, for now,
        # if this throws, it's self-accredited.
        begin
          course.accrediting_provider&.provider_name || @provider.provider_name
        rescue StandardError
          @provider.provider_name
        end
      }
      .sort_by { |accrediting_provider, _| accrediting_provider }
      .map { |provider_name, courses|
      [provider_name, courses.sort_by { |course| [course.name, course.course_code] }
                             .map(&:decorate)]
    }
      .to_h
    # rubocop:enable Style/MultilineBlockChain

    @self_accredited_courses = @courses_by_accrediting_provider.delete(@provider.provider_name)
  end

  def filter_courses
    @courses_by_accrediting_provider = @courses_by_accrediting_provider.reject { |c| c == course.id }
    @self_accredited_courses = @self_accredited_courses&.reject { |c| c.id == course.id }
  end

  def build_copy_course
    @source_course = Course.includes(:sites)
                           .includes(provider: [:sites])
                           .includes(:accrediting_provider)
                           .where(provider_code: @provider_code)
                           .find(params[:copy_from])
                           .first
  end

  def copy_field_if_present_in_source_course(field)
    source_value = @source_course[field]
    course[field] = source_value if source_value.present?
  end
end
