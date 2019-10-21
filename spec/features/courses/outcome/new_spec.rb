require "rails_helper"

feature "new course outcome", type: :feature do
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider) }
  let(:empty_build_course_request) { stub_api_v2_build_course }

  before do
    stub_omniauth
    stub_api_v2_resource(provider.recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course(qualification: "qts")
    new_course = build(:course, :new, provider: provider, gcse_subjects_required_using_level: true)
    stub_api_v2_new_resource(new_course)
    empty_build_course_request

    visit_new_outcome_page
  end

  scenario "sends user back to course confirmation" do
    visit_new_outcome_page(goto_confirmation: true)

    new_outcome_page.qualification_fields.qts.choose
    new_outcome_page.continue.click

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  context "Loading the page" do
    scenario "It builds the course on the backend" do
      expect(empty_build_course_request).to have_been_made
    end
  end

  context "Selecting QTS" do
    let(:next_step_page) do
      PageObjects::Page::Organisations::Courses::NewFeeOrSalaryPage.new
    end
    let(:selected_fields) { { qualification: "qts" } }
    let(:build_course_with_selected_value_request) { stub_api_v2_build_course(qualification: "qts") }

    before do
      build_course_with_selected_value_request
      choose("course_qualification_qts")
      click_on "Continue"
    end

    it_behaves_like "a course creation page"

    context "With an accredited body provider" do
      let(:provider) { build(:provider, accredited_body?: true) }
      let(:next_step_page) do
        PageObjects::Page::Organisations::Courses::NewApprenticeshipPage.new
      end

      it_behaves_like "a course creation page"
    end
  end

private

  def visit_new_outcome_page(**query_params)
    visit new_provider_recruitment_cycle_courses_outcome_path(
      provider.provider_code,
      provider.recruitment_cycle.year,
      query_params,
    )
  end
end
