require "rails_helper"

feature "new course", type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:new_level_page) do
    PageObjects::Page::Organisations::Courses::NewLevelPage.new
  end
  let(:new_subjects_page) do
    PageObjects::Page::Organisations::Courses::NewSubjectsPage.new
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
  let(:new_locations_page) do
    PageObjects::Page::Organisations::Courses::NewLocationsPage.new
  end
  let(:confirmation_page) do
    PageObjects::Page::Organisations::CourseConfirmation.new
  end
  let(:build_new_course_request) { stub_api_v2_build_course }
  let(:site1) { build(:site, location_name: "Site one") }
  let(:site2) { build(:site, location_name: "Site two") }
  let(:provider) { build(:provider, sites: [site1, site2]) }
  let(:english) { build(:subject, :english) }

  let(:course) do
    model = build :course,
                  :new,
                  level: :primary,
                  provider: provider,
                  course_code: "A123",
                  content_status: "draft",
                  subjects: [build(:subject, subject_name: "Primary with Mathematics")],
                  gcse_subjects_required: %w[maths science english]
    model.meta[:edit_options][:subjects] = [english]
    model
  end
  let(:course_creation_request) do
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses",
      course.to_jsonapi,
      :post, 200
    )
  end

  before do
    stub_omniauth
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider, include: "sites")
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
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
        course_creation_params = select_subjects(course_creation_params)
        course_creation_params = select_age_range(course_creation_params)
        course_creation_params = select_outcome(course_creation_params)
        course_creation_params = select_apprenticeship(course_creation_params)
        course_creation_params = select_study_mode(course_creation_params)
        course_creation_params = select_location(course_creation_params)
        course_creation_params = select_entry_requirements(course_creation_params)
        course_creation_params = select_applications_open_from(course_creation_params)

        select_start_date(course_creation_params)

        # Add a temporary name
        course.name = "Temporary name"
        course_creation_params[:name] = "Temporary name"

        save_course

        expect(
          course_creation_request.with do |request|
            request_attributes = JSON.parse(request.body)["data"]["attributes"]
            expect(request_attributes.symbolize_keys).to eq(course_creation_params)
          end,
        ).to have_been_made

        expect(
          course_creation_request.with do |request|
            request_relationships = JSON.parse(request.body)["data"]["relationships"]
            expect(request_relationships).to eq(
              "subjects" => {
                "data" => [
                  {
                    "type" => "subjects",
                    "id" => english.id,
                  },
                ],
              },
            )
          end,
        ).to have_been_made
      end
    end
  end

private

  def save_course
    course_creation_request
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    confirmation_page.save.click
  end

  def select_level(course_creation_params)
    course_creation_params[:level] = "primary"
    course_creation_params[:is_send] = "0"
    stub_build_course_with_params(course_creation_params)

    new_level_page.level_fields.primary.click
    new_level_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: new_subjects_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_subjects(course_creation_params)
    course_creation_params[:level] = "primary"
    course_creation_params[:subjects_ids] = [english.id]
    stub_build_course_with_params(course_creation_params)

    new_subjects_page.subjects_fields.select(english.subject_name)
    new_subjects_page.continue.click

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
      page: new_locations_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_location(course_creation_params)
    course_creation_params[:sites_ids] = [site1.id, site2.id]
    course.sites = [site1, site2]
    stub_build_course_with_params(course_creation_params)

    new_locations_page.check(site1.location_name)
    new_locations_page.check(site2.location_name)
    new_locations_page.continue.click

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
    current_query_string = current_url.match('\?(.*)$').captures.first
    url_params = { course: expected_query_params }

    expect(page).to be_displayed
    expect(current_query_string).to eq(url_params.to_query)
  end

  def initial_params
    {
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
    }
  end
end
