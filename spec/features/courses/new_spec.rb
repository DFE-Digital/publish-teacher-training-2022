require "rails_helper"

feature 'new course', type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:new_level_page) do
    PageObjects::Page::Organisations::Courses::NewLevelPage.new
  end
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:new_entry_requirements_page) do
    PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new
  end
  let(:build_new_course_request) { stub_api_v2_build_course }
  let(:build_new_course_with_outcome_request) do
    stub_api_v2_build_course('qualification' => 'qts')
  end
  let(:build_new_course_with_outcome_and_entry_requirements_request) do
    stub_api_v2_build_course(
      'qualification' => 'qts',
      'english' => 'must_have_qualification_at_application_time',
      'maths' => 'must_have_qualification_at_application_time',
      'science' => 'must_have_qualification_at_application_time'
    )
  end
  let(:build_new_course_with_outcome_2_and_entry_requirements_request) do
    stub_api_v2_build_course(
      'qualification' => 'pgce_with_qts',
      'english' => 'must_have_qualification_at_application_time',
      'maths' => 'must_have_qualification_at_application_time',
      'science' => 'must_have_qualification_at_application_time'
    )
  end
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
    build_new_course_with_outcome_request
    build_new_course_with_outcome_and_entry_requirements_request
    build_new_course_with_outcome_2_and_entry_requirements_request
  end

  context 'Beginning the course creation flow' do
    scenario "builds the new course on the API" do
      go_to_new_course_page_for_provider(provider)

      expect(build_new_course_request).to have_been_made
    end

    scenario 'redirects and renders new course outcome page' do
      go_to_new_course_page_for_provider(provider)

      expect(current_path).to eq new_provider_recruitment_cycle_courses_outcome_path(provider.provider_code, provider.recruitment_cycle_year)

      expect(new_outcome_page).to(
        be_displayed(
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code
        )
      )

      # The qualifications for a new course that hasn't had it's level set just
      # happens to result in these qualifications. This will change when the new
      # course flow properly sets the level of the course.
      expect(new_outcome_page).to have_qualification_fields
      expect(new_outcome_page.qualification_fields).to have_qts
      expect(new_outcome_page.qualification_fields).to have_pgce_with_qts
      expect(new_outcome_page.qualification_fields).to have_pgde_with_qts
      new_outcome_page.qualification_fields.qts.click
    end
  end

  context 'course creation flow' do
    scenario 'creates the correct course' do
      # This is intended to be a test which will go through the entire flow
      # and ensure that the correct page gets displayed at the end
      # with the correct course being created

      go_to_new_course_page_for_provider(provider)

      expect(new_outcome_page).to be_displayed
      new_outcome_page.qualification_fields.qts.click
      stub_api_v2_new_resource(course)
      new_outcome_page.continue.click

      expect_page_to_be_displayed_with_query(
        page: new_entry_requirements_page,
        expected_query: {
          'course[qualification]' => 'qts'
        }
      )

      select_entry_requirements

      # They loop for now

      expect_page_to_be_displayed_with_query(
        page: new_outcome_page,
        expected_query: {
          'course[qualification]' => 'qts',
          'course[english]' => 'must_have_qualification_at_application_time',
          'course[maths]' => 'must_have_qualification_at_application_time',
          'course[science]' => 'must_have_qualification_at_application_time'
        }
      )

      # Ensure that everything gets carried through for course creation

      new_outcome_page.qualification_fields.pgce_with_qts.click
      stub_api_v2_new_resource(course)
      new_outcome_page.continue.click

      expect_page_to_be_displayed_with_query(
        page: new_entry_requirements_page,
        expected_query: {
          'course[qualification]' => 'pgce_with_qts',
          'course[english]' => 'must_have_qualification_at_application_time',
          'course[maths]' => 'must_have_qualification_at_application_time',
          'course[science]' => 'must_have_qualification_at_application_time'
        }
      )
    end
  end

private

  def go_to_new_course_page_for_provider(provider)
    visit new_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  def expect_page_to_be_displayed_with_query(page:, expected_query:)
    expect(page).to be_displayed
    query = page.url_matches['query']
    expect(query).to eq(expected_query)
  end

  def select_entry_requirements
    new_entry_requirements_page.maths_requirements.choose('course_maths_must_have_qualification_at_application_time')
    new_entry_requirements_page.english_requirements.choose('course_english_must_have_qualification_at_application_time')
    new_entry_requirements_page.science_requirements.choose('course_science_must_have_qualification_at_application_time')
    new_entry_requirements_page.continue.click
  end

  def initial_params
    {
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year
    }
  end
end
