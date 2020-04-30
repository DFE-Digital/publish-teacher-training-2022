require "rails_helper"

feature "new course", type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:new_level_page) do
    PageObjects::Page::Organisations::Courses::NewLevelPage.new
  end
  let(:new_subjects_page) do
    PageObjects::Page::Organisations::Courses::NewSubjectsPage.new
  end
  let(:new_modern_languages_page) do
    PageObjects::Page::Organisations::Courses::NewModernLanguagesPage.new
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
  let(:sites) { [site1, site2] }
  let(:provider) { build(:provider, accredited_body?: true, sites: sites) }
  let(:english) { build(:subject, :english) }
  let(:modern_languages) { build(:subject, :modern_languages) }
  let(:russian) { build(:subject, :russian) }

  let(:course) do
    model = build(:course,
                  :new,
                  level: level,
                  provider: provider,
                  course_code: "A123",
                  content_status: "draft",
                  subjects: [build(:subject, subject_name: "Primary with Mathematics")],
                  gcse_subjects_required: %w[maths science english])
    model.meta[:edit_options][:subjects] = [english]
    model.meta[:edit_options][:modern_languages_subject] = modern_languages
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
    stub_omniauth(provider: provider)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider, include: "sites")
    stub_api_v2_new_resource(course)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    build_new_course_request
  end

  context "Beginning the course creation flow" do
    context "SCITT with single location" do
      let(:level) { :primary }

      scenario "builds the new course on the API" do
        go_to_new_course_page_for_provider(provider)

        expect(build_new_course_request).to have_been_made
      end

      context "given the provider has no existing courses" do
        let(:provider) { build(:provider) }
        before do
          stub_api_v2_resource_collection([], endpoint: "#{url_for_resource(provider)}/courses?include=subjects,sites,provider.sites,accrediting_provider")
        end

        it "displays the page" do
          expect { go_to_new_course_page_for_provider(provider) }.not_to raise_error
        end
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

      scenario "creates the correct course" do
        # This is intended to be a test which will go through the entire flow
        # and ensure that the correct page gets displayed at the end
        # with the correct course being created
        go_to_new_course_page_for_provider(provider)

        expect(new_level_page).to be_displayed
        course_creation_params = select_level({}, level: "primary", level_selection: new_level_page.level_fields.primary, next_page: new_subjects_page)
        course_creation_params = select_subjects(course_creation_params, level: "primary", next_page: new_age_range_page)
        course_creation_params = select_age_range(course_creation_params, next_page: new_outcome_page)
        course_creation_params = select_outcome(course_creation_params, qualification: "qts", qualification_selection: new_outcome_page.qualification_fields.qts, next_page: new_apprenticeship_page)
        course_creation_params = select_apprenticeship(course_creation_params, next_page: new_study_mode_page)
        course_creation_params = select_study_mode(course_creation_params, next_page: new_locations_page)
        course_creation_params = select_location(course_creation_params, next_page: new_entry_requirements_page)
        course_creation_params = select_entry_requirements(course_creation_params, next_page: new_applications_open_page)
        course_creation_params = select_applications_open_from(course_creation_params, next_page: new_start_date_page)

        select_start_date(course_creation_params)
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
              "sites" => {
                "data" => [
                  {
                    "type" => "sites",
                    "id" => site1.id,
                  },
                  {
                    "type" => "sites",
                    "id" => site2.id,
                  },
                ],
              },
            )
          end,
        ).to have_been_made
      end
    end

    context "Further education provider with single location" do
      let(:level) { :further_education }

      scenario "creates the correct course" do
        # This is intended to be a test which will go through the entire flow
        # and ensure that the correct page gets displayed at the end
        # with the correct course being created
        go_to_new_course_page_for_provider(provider)

        expect(new_level_page).to be_displayed
        course_creation_params = select_level({}, level: "further_education", level_selection: new_level_page.level_fields.further_education, next_page: new_outcome_page)
        course_creation_params = select_outcome(course_creation_params, qualification: "pgce", qualification_selection: new_outcome_page.qualification_fields.pgce, next_page: new_study_mode_page)
        course_creation_params = select_study_mode(course_creation_params, next_page: new_locations_page)
        course_creation_params = select_location(course_creation_params, next_page: new_applications_open_page)
        course_creation_params = select_applications_open_from(course_creation_params, next_page: new_start_date_page)

        select_start_date(course_creation_params)

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
                "data" => nil,
              },
              "sites" => {
                "data" => [
                  {
                    "type" => "sites",
                    "id" => site1.id,
                  },
                  {
                    "type" => "sites",
                    "id" => site2.id,
                  },
                ],
              },
            )
          end,
        ).to have_been_made
      end
    end
  end

  context "going backwards through the course creation flow" do
    context "with one site and no modern language subjects" do
      let(:level) { :primary }
      let(:sites) { [site1] }
      let(:course_creation_params) do
        {
          level: "primary",
          is_send: "0",
          qualification: "pgce",
          study_mode: "full_time",
          funding_type: "fee",
          sites_ids: [site1.id],
          applications_open_from: "2018-10-09",
        }
      end

      let(:course) do
        model = build(:course,
                      :new,
                      level: level,
                      provider: provider,
                      study_mode: "fee",
                      course_code: "A123",
                      content_status: "draft",
                      applications_open_from: DateTime.parse(recruitment_cycle.application_start_date).utc.iso8601,
                      subjects: [build(:subject, subject_name: "Primary with Mathematics")],
                      gcse_subjects_required: %w[maths science english])
        model.meta[:edit_options][:subjects] = [english]
        model.meta[:edit_options][:modern_languages_subject] = modern_languages

        model
      end

      it "can skip steps that are not relevant" do
        stub_api_v2_build_course(course_creation_params)

        visit new_provider_recruitment_cycle_courses_start_date_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
          course: course_creation_params,
        )

        new_start_date_page.back.click
        expect(new_applications_open_page).to be_displayed
        new_start_date_page.back.click
        expect(new_entry_requirements_page).to be_displayed
        new_entry_requirements_page.back.click
        expect(new_study_mode_page).to be_displayed
        new_study_mode_page.back.click
        expect(new_apprenticeship_page).to be_displayed
        new_apprenticeship_page.back.click
        expect(new_outcome_page).to be_displayed
        new_outcome_page.back.click
        expect(new_age_range_page).to be_displayed
        new_age_range_page.back.click
        expect(new_subjects_page).to be_displayed
        new_subjects_page.back.click
        expect(new_level_page).to be_displayed
      end
    end

    context "with multiple sites and modern language subjects" do
      let(:level) { :secondary }
      let(:sites) { [site1, site2] }
      let(:course_creation_params) do
        {
          level: "secondary",
          is_send: "0",
          qualification: "pgce",
          study_mode: "full_time",
          funding_type: "fee",
          sites_ids: [site1.id, site2.id],
          applications_open_from: "2018-10-09",
        }
      end

      let(:course) do
        model = build(:course,
                      :new,
                      level: level,
                      provider: provider,
                      study_mode: "fee",
                      course_code: "A123",
                      content_status: "draft",
                      applications_open_from: DateTime.parse(recruitment_cycle.application_start_date).utc.iso8601,
                      subjects: [modern_languages, russian],
                      gcse_subjects_required: %w[maths science english])
        model.meta[:edit_options][:subjects] = [modern_languages]
        model.meta[:edit_options][:modern_languages] = [russian]
        model.meta[:edit_options][:modern_languages_subject] = modern_languages

        model
      end

      it "can skip steps that are not relevant" do
        stub_api_v2_build_course(course_creation_params)

        visit new_provider_recruitment_cycle_courses_start_date_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
          course: course_creation_params,
        )

        new_start_date_page.back.click
        expect(new_applications_open_page).to be_displayed
        new_start_date_page.back.click
        expect(new_entry_requirements_page).to be_displayed
        new_entry_requirements_page.back.click
        expect(new_locations_page).to be_displayed
        new_locations_page.back.click
        expect(new_study_mode_page).to be_displayed
        new_study_mode_page.back.click
        expect(new_apprenticeship_page).to be_displayed
        new_apprenticeship_page.back.click
        expect(new_outcome_page).to be_displayed
        new_outcome_page.back.click
        expect(new_age_range_page).to be_displayed
        new_age_range_page.back.click
        expect(new_modern_languages_page).to be_displayed
        new_modern_languages_page.back.click
        expect(new_subjects_page).to be_displayed
        new_subjects_page.back.click
        expect(new_level_page).to be_displayed
      end
    end
  end

private

  def save_course
    course_creation_request
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    confirmation_page.save.click
  end

  def select_level(course_creation_params, level:, level_selection:, next_page:)
    course_creation_params[:level] = level
    course_creation_params[:is_send] = "0"
    stub_api_v2_build_course(course_creation_params)

    level_selection.click
    new_level_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_subjects(course_creation_params, level:, next_page:)
    course_creation_params[:level] = level
    course_creation_params[:subjects_ids] = [english.id]
    stub_api_v2_build_course(course_creation_params)

    new_subjects_page.subjects_fields.select(english.subject_name)
    new_subjects_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_age_range(course_creation_params, next_page:)
    course_creation_params[:age_range_in_years] = "5_to_11"
    stub_api_v2_build_course(course_creation_params)

    choose("course_age_range_in_years_5_to_11")
    click_on "Continue"

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_outcome(course_creation_params, qualification:, qualification_selection:, next_page:)
    course_creation_params[:qualification] = qualification
    stub_api_v2_build_course(course_creation_params)

    qualification_selection.click
    new_outcome_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_apprenticeship(course_creation_params, next_page:)
    course_creation_params[:funding_type] = "fee"
    stub_api_v2_build_course(course_creation_params)

    new_apprenticeship_page.funding_type_fields.fee.click
    new_apprenticeship_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_study_mode(course_creation_params, next_page:)
    course_creation_params[:study_mode] = "full_time"
    course.study_mode = "full_time"
    stub_api_v2_build_course(course_creation_params)

    new_study_mode_page.study_mode_fields.full_time.click
    new_study_mode_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_location(course_creation_params, next_page:)
    course_creation_params[:sites_ids] = [site1.id, site2.id]
    course.sites = [site1, site2]
    stub_api_v2_build_course(course_creation_params)

    new_locations_page.check(site1.location_name)
    new_locations_page.check(site2.location_name)
    new_locations_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_applications_open_from(course_creation_params, next_page:)
    course_creation_params[:applications_open_from] = recruitment_cycle.application_start_date
    course.applications_open_from = DateTime.parse(recruitment_cycle.application_start_date).utc.iso8601
    stub_api_v2_build_course(course_creation_params)

    new_applications_open_page.applications_open_field.click
    new_applications_open_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_start_date(course_creation_params)
    course_creation_params[:start_date] = "September 2020"
    course.start_date = Time.zone.local(2019, 9)
    stub_api_v2_build_course(course_creation_params)

    new_start_date_page.select "September 2020"
    new_start_date_page.continue.click

    # Addressable, the gem site-prism relies on, cannot match parameters containing a +
    # https://github.com/sporkmonger/addressable/issues/142
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

  def select_entry_requirements(course_creation_params, next_page:)
    course_creation_params[:english] = "must_have_qualification_at_application_time"
    course_creation_params[:maths] = "must_have_qualification_at_application_time"
    course_creation_params[:science] = "must_have_qualification_at_application_time"
    stub_api_v2_build_course(course_creation_params)

    new_entry_requirements_page.maths_requirements.choose("course_maths_must_have_qualification_at_application_time")
    new_entry_requirements_page.english_requirements.choose("course_english_must_have_qualification_at_application_time")
    new_entry_requirements_page.science_requirements.choose("course_science_must_have_qualification_at_application_time")
    new_entry_requirements_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
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
