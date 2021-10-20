require "rails_helper"

feature "new course apprenticeship", type: :feature do
  let(:new_apprenticeship_page) do
    PageObjects::Page::Organisations::Courses::NewApprenticeshipPage.new
  end
  let(:course) do
    build(
      :course,
      :new,
      provider: provider,
      gcse_subjects_required: %w[maths science english],
      study_mode: "full_time_or_part_time",
      gcse_subjects_required_using_level: true,
      applications_open_from: "2019-10-09",
      start_date: "2019-10-09",
      level: "secondary",
    )
  end
  let(:provider) { build(:provider, accredited_body?: true) }
  let(:recruitment_cycle) { build(:recruitment_cycle) }

  before do
    signed_in_user
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider, include: "sites")
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course
    stub_api_v2_build_course(funding_type: "apprenticeship")
    visit new_provider_recruitment_cycle_courses_apprenticeship_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  scenario "presents the correct choices" do
    expect(new_apprenticeship_page).to have_funding_type_fields
    expect(new_apprenticeship_page.funding_type_fields).to have_apprenticeship
    expect(new_apprenticeship_page.funding_type_fields).to have_fee
  end

  scenario "sends user to entry requirements" do
    new_apprenticeship_page.funding_type_fields.apprenticeship.click
    new_apprenticeship_page.continue.click

    expect(current_path).to eq new_provider_recruitment_cycle_courses_study_mode_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  scenario "sends user back to course confirmation" do
    visit_new_apprenticeship_page(goto_confirmation: true)

    new_apprenticeship_page.funding_type_fields.apprenticeship.click
    new_apprenticeship_page.continue.click

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  context "Higher education program type" do
    let(:next_step_page) do
      PageObjects::Page::Organisations::Courses::NewStudyModePage.new
    end
    let(:selected_fields) { { funding_type: "apprenticeship" } }
    let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

    before do
      new_apprenticeship_page.funding_type_fields.apprenticeship.click
      new_apprenticeship_page.continue.click
    end

    it_behaves_like "a course creation page"
  end

  context "Error handling" do
    let(:course) do
      c = build(:course, provider: provider)
      c.errors.add(:funding_type, "Invalid")
      c.errors.add(:program_type, "Invalid")
      c
    end

    scenario "error flash" do
      visit_new_apprenticeship_page
      new_apprenticeship_page.funding_type_fields.apprenticeship.click
      new_apprenticeship_page.continue.click
      expect(new_apprenticeship_page.error_flash.text).to include("Funding type Invalid")
      expect(new_apprenticeship_page.error_flash.text).to include("Program type Invalid")
    end

    scenario "inline error messages" do
      visit_new_apprenticeship_page
      new_apprenticeship_page.funding_type_fields.apprenticeship.click
      new_apprenticeship_page.continue.click
      expect(new_apprenticeship_page.funding_type_error.text).to include("Error: Funding type Invalid")
      expect(new_apprenticeship_page.program_type_error.text).to include("Error: Program type Invalid")
    end
  end

  def visit_new_apprenticeship_page(**query_params)
    visit new_provider_recruitment_cycle_courses_apprenticeship_path(provider.provider_code, provider.recruitment_cycle_year, query_params)
  end
end
