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
      accrediting_provider: build(:provider),
    )
  end
  let(:provider) { build(:provider, sites: [build(:site), build(:site)]) }
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

  context "It allows the user to go back" do
    context "When they are an accredited body" do
      let(:provider) { build(:provider, accredited_body?: true) }
      let(:new_apprenticeship_page) { PageObjects::Page::Organisations::Courses::NewApprenticeshipPage.new }

      it "Returns to the study mode page" do
        visit_new_study_mode_page
        new_study_mode_page.back.click
        expect(new_apprenticeship_page).to be_displayed
      end
    end

    context "when they are not an accredited body" do
      let(:new_fee_or_salary_page) { PageObjects::Page::Organisations::Courses::NewFeeOrSalaryPage.new }

      it "Returns to the locations page" do
        visit_new_study_mode_page
        new_study_mode_page.back.click
        expect(new_fee_or_salary_page).to be_displayed
      end
    end
  end

  context "Error handling" do
    let(:course) do
      c = build(:course, provider: provider, study_mode: nil)
      c.errors.add(:study_mode, "Invalid")
      c
    end

    scenario do
      visit_new_study_mode_page
      new_study_mode_page.continue.click
      expect(new_study_mode_page.error_flash.text).to include("Pick full time, part time or full time and part time")
    end
  end

  context "Page title" do
    before do
      visit_new_study_mode_page
    end
    scenario "It displays the correct title" do
      expect(page.title).to start_with("Full time or part time?")
    end
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
