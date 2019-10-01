require "rails_helper"

feature "new course", type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:new_level_page) do
    PageObjects::Page::Organisations::Courses::NewLevelPage.new
  end
  let(:new_age_range_page) do
    PageObjects::Page::Organisations::Courses::NewAgeRangePage.new
  end
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:new_apprenticeship_page) do
    PageObjects::Page::Organisations::Courses::NewApprenticeshipPage.new
  end
  let(:new_study_mode_page) do
    PageObjects::Page::Organisations::Courses::NewStudyModePage.new
  end
  let(:new_applications_open_page) do
    PageObjects::Page::Organisations::Courses::NewApplicationsOpenPage.new
  end
  let(:new_start_date_page) do
    PageObjects::Page::Organisations::Courses::NewStartDatePage.new
  end
  let(:new_entry_requirements_page) do
    PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new
  end
  let(:confirmation_page) do
    PageObjects::Page::Organisations::CourseConfirmation.new
  end
  let(:build_new_course_request) { stub_api_v2_build_course }
  let(:provider) { build(:provider) }
  let(:course) do
    build :course,
          :new,
          level: :primary,
          provider: provider,
          subjects: %w[English],
          gcse_subjects_required: %w[maths science english]
  end

  before do
    stub_omniauth
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_resource_collection([course], include: "sites,provider.sites,accrediting_provider")
    stub_api_v2_new_resource(course)
    build_new_course_request
  end

  context "Beginning the course creation flow" do
    scenario "builds the new course on the API" do
      go_to_new_course_page_for_provider(provider)

      expect(build_new_course_request).to have_been_made
    end

    scenario "redirects and renders new course level page" do
      go_to_new_course_page_for_provider(provider)

      expect(current_path).to eq new_provider_recruitment_cycle_courses_level_path(provider.provider_code, provider.recruitment_cycle_year)

      expect(new_level_page).to(
        be_displayed(
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code,
        ),
      )
    end
  end

  context "course creation flow" do
    context "SCITT with single location" do
      scenario "creates the correct course" do
        # This is intended to be a test which will go through the entire flow
        # and ensure that the correct page gets displayed at the end
        # with the correct course being created
        go_to_new_course_page_for_provider(provider)

        expect(new_level_page).to be_displayed
        course_creation_params = select_level({})
        course_creation_params = select_age_range(course_creation_params)
        course_creation_params = select_outcome(course_creation_params)
        course_creation_params = select_apprenticeship(course_creation_params)
        course_creation_params = select_study_mode(course_creation_params)
        course_creation_params = select_entry_requirements(course_creation_params)
        course_creation_params = select_applications_open_from(course_creation_params)

        _course_creation_params = select_start_date(course_creation_params)

        ## Next step: Test that it hits the course create endpoint on the API
      end
    end
  end

private

  def select_level(course_creation_params)
    course_creation_params[:level] = "primary"
    course_creation_params[:is_send] = "0"
    stub_build_course_with_params(course_creation_params)

    new_level_page.level_fields.primary.click
    new_level_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: new_age_range_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_age_range(course_creation_params)
    course_creation_params[:age_range_in_years] = "5_to_11"
    stub_build_course_with_params(course_creation_params)

    choose("course_age_range_in_years_5_to_11")
    click_on "Continue"

    expect_page_to_be_displayed_with_query(
      page: new_outcome_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_outcome(course_creation_params)
    course_creation_params[:qualification] = "qts"
    stub_build_course_with_params(course_creation_params)

    new_outcome_page.qualification_fields.qts.click
    new_outcome_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: new_apprenticeship_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_apprenticeship(course_creation_params)
    course_creation_params[:funding_type] = "fee"
    stub_build_course_with_params(course_creation_params)

    new_apprenticeship_page.funding_type_fields.fee.click
    new_apprenticeship_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: new_study_mode_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_study_mode(course_creation_params)
    course_creation_params[:study_mode] = "full_time"
    course.study_mode = "full_time"
    stub_build_course_with_params(course_creation_params)

    new_study_mode_page.study_mode_fields.full_time.click
    new_study_mode_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: new_entry_requirements_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_applications_open_from(course_creation_params)
    course_creation_params[:applications_open_from] = recruitment_cycle.application_start_date
    course.applications_open_from = DateTime.parse(recruitment_cycle.application_start_date).utc.iso8601
    stub_build_course_with_params(course_creation_params)

    new_applications_open_page.applications_open_field.click
    new_applications_open_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: new_start_date_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_start_date(course_creation_params)
    course_creation_params[:start_date] = "September 2020"
    course.start_date = Time.zone.local(2019, 9)
    stub_build_course_with_params(course_creation_params)

    new_start_date_page.select "September 2020"
    new_start_date_page.continue.click

    #Addressable, the gem site-prism relies on, cannot match parameters containing a +
    #https://github.com/sporkmonger/addressable/issues/142
    # Addressable::Template.new('/a{?query*}').match(Addressable::URI.parse('/a?a=b+b')) == false
    # Addressable::Template.new('/a{?query*}').match(Addressable::URI.parse('/a?a=b')) == true
    # To work around this - we need to manually match the URL and query params for this request

    current_query_string = URI.parse(page.current_url).query
    current_course_params = Rack::Utils.parse_nested_query(current_query_string)["course"].symbolize_keys

    expect(page.current_path).to eq(
      confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year),
    )
    expect(current_course_params).to eq(course_creation_params)

    course_creation_params
  end

  def select_entry_requirements(course_creation_params)
    course_creation_params[:english] = "must_have_qualification_at_application_time"
    course_creation_params[:maths] = "must_have_qualification_at_application_time"
    course_creation_params[:science] = "must_have_qualification_at_application_time"
    stub_build_course_with_params(course_creation_params)

    new_entry_requirements_page.maths_requirements.choose("course_maths_must_have_qualification_at_application_time")
    new_entry_requirements_page.english_requirements.choose("course_english_must_have_qualification_at_application_time")
    new_entry_requirements_page.science_requirements.choose("course_science_must_have_qualification_at_application_time")
    new_entry_requirements_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: new_applications_open_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def stub_build_course_with_params(params)
    stub_api_v2_build_course(params)
  end

  def go_to_new_course_page_for_provider(provider)
    visit new_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  def expect_page_to_be_displayed_with_query(page:, expected_query_params:)
    url_params = {}
    expected_query_params.each { |k, v| url_params["course[#{k}]"] = v }

    expect(page).to be_displayed
    query = page.url_matches["query"]
    expect(query).to eq(url_params)
  end

  def initial_params
    {
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
    }
  end
end
