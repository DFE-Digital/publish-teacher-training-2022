require "rails_helper"

feature "new course", type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:new_level_page) do
    PageObjects::Page::Organisations::Courses::NewLevelPage.new
  end
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:new_apprenticeship_page) do
    PageObjects::Page::Organisations::Courses::NewApprenticeshipPage.new
  end
  let(:new_entry_requirements_page) do
    PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new
  end
  let(:build_new_course_request) { stub_api_v2_build_course }
  let(:provider) { build(:provider) }
  let(:course) do
    build :course,
          :new,
          provider: provider,
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

    scenario "redirects and renders new course outcome page" do
      go_to_new_course_page_for_provider(provider)

      expect(current_path).to eq new_provider_recruitment_cycle_courses_level_path(provider.provider_code, provider.recruitment_cycle_year)

      expect(new_level_page).to(
        be_displayed(
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code,
        ),
      )

      # The qualifications for a new course that hasn't had it's level set just
      # happens to result in these qualifications. This will change when the new
      # course flow properly sets the level of the course.
      # expect(new_outcome_page).to have_qualification_fields
      # expect(new_outcome_page.qualification_fields).to have_qts
      # expect(new_outcome_page.qualification_fields).to have_pgce_with_qts
      # expect(new_outcome_page.qualification_fields).to have_pgde_with_qts
      # new_outcome_page.qualification_fields.qts.click
    end
  end

  context 'course creation flow' do
    context 'SCITT' do
      scenario 'creates the correct course' do
        # This is intended to be a test which will go through the entire flow
        # and ensure that the correct page gets displayed at the end
        # with the correct course being created
        go_to_new_course_page_for_provider(provider)

        expect(new_level_page).to be_displayed
        course_creation_params = select_level({})
        course_creation_params = select_outcome(course_creation_params)
        course_creation_params = select_apprenticeship(course_creation_params)
        _course_creation_params = select_entry_requirements(course_creation_params)
      end
    end
  end

private

  def select_level(course_creation_params)
    course_creation_params[:level] = 'primary'
    course_creation_params[:is_send] = '0'
    stub_build_course_with_params(course_creation_params)

    new_level_page.level_fields.primary.click
    new_level_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: new_outcome_page,
      expected_query_params: course_creation_params
    )

    course_creation_params
  end

  def select_outcome(course_creation_params)
    course_creation_params[:qualification] = 'qts'
    stub_build_course_with_params(course_creation_params)

    new_outcome_page.qualification_fields.qts.click
    new_outcome_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: new_apprenticeship_page,
      expected_query_params: course_creation_params
    )

    course_creation_params
  end

  def select_apprenticeship(course_creation_params)
    course_creation_params[:program_type] = 'pg_teaching_apprenticeship'
    stub_build_course_with_params(course_creation_params)

    new_outcome_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: new_entry_requirements_page,
      expected_query_params: course_creation_params
    )

    course_creation_params
  end

  def select_entry_requirements(course_creation_params)
    course_creation_params[:english] = 'must_have_qualification_at_application_time'
    course_creation_params[:maths] = 'must_have_qualification_at_application_time'
    course_creation_params[:science] = 'must_have_qualification_at_application_time'
    stub_build_course_with_params(course_creation_params)

    new_entry_requirements_page.maths_requirements.choose('course_maths_must_have_qualification_at_application_time')
    new_entry_requirements_page.english_requirements.choose('course_english_must_have_qualification_at_application_time')
    new_entry_requirements_page.science_requirements.choose('course_science_must_have_qualification_at_application_time')
    new_entry_requirements_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: new_outcome_page,
      expected_query_params: course_creation_params
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
    query = page.url_matches['query']
    expect(query).to eq(url_params)
  end

  def initial_params
    {
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
    }
  end
end
