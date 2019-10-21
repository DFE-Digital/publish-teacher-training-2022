require "rails_helper"

feature "new course study mode", type: :feature do
  let(:new_study_mode_page) do
    PageObjects::Page::Organisations::Courses::NewStudyModePage.new
  end
  let(:new_locations_page) do
    PageObjects::Page::Organisations::Courses::NewLocationsPage.new
  end

  let(:course) do
    build(
      :course,
      :new,
      provider: provider,
      gcse_subjects_required: %w[maths science english],
      study_mode: "full_time",
      applications_open_from: "2019-10-09",
      start_date: "2019-10-09",
    )
  end
  let(:provider) { build(:provider) }
  let(:recruitment_cycle) { build(:recruitment_cycle) }

  before do
    stub_omniauth(provider: provider)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider, include: "sites")
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course
    stub_api_v2_build_course(study_mode: "full_time_or_part_time")
  end

  scenario "sends user to confirmation page" do
    visit_new_study_mode_page

    expect(new_study_mode_page).to have_study_mode_fields
    expect(new_study_mode_page.study_mode_fields)
      .to have_selector('[for="course_study_mode_full_time"]', text: "Full time")
    expect(new_study_mode_page.study_mode_fields)
      .to have_selector('[for="course_study_mode_part_time"]', text: "Part time")
    expect(new_study_mode_page.study_mode_fields)
      .to have_selector('[for="course_study_mode_full_time_or_part_time"]', text: "Full time or part time")

    new_study_mode_page.study_mode_fields.full_time_or_part_time.click

    click_on "Continue"

    expect(new_locations_page).to be_displayed
  end

  scenario "sends user back to course confirmation" do
    visit_new_study_mode_page(goto_confirmation: true)
    new_study_mode_page.study_mode_fields.full_time_or_part_time.click
    new_study_mode_page.continue.click

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end

private

  def visit_new_study_mode_page(**query_params)
    visit signin_path
    visit new_provider_recruitment_cycle_courses_study_mode_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      query_params,
    )
  end
end
