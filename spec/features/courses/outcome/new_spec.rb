require "rails_helper"

feature "new course outcome", type: :feature do
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider) }
  let(:empty_build_course_request) { stub_api_v2_build_course }
<<<<<<< HEAD
  let(:build_course_with_qualification_request) { stub_api_v2_build_course(qualification: "qts") }
=======
>>>>>>> 4d86ff8... [2026] Refactor new page tests to shared examples

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider, gcse_subjects_required_using_level: true)
    stub_api_v2_new_resource(new_course)
    empty_build_course_request

    visit_new_outcome_page
  end

  context "Loading the page" do
    scenario "It builds the course on the backend" do
      expect(empty_build_course_request).to have_been_made
    end
  end

<<<<<<< HEAD
  context "Selecting QTS" do
    before do
      choose("course_qualification_qts")
      click_on "Continue"
    end

    scenario "sends user to entry requirements" do
      expect(new_entry_requirements_page).to be_displayed(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
      )
    end

    scenario "stores the qualification in the URL" do
      expect(new_entry_requirements_page.url_matches["query"]).to eq("course[qualification]" => "qts")
    end

    scenario "it builds the course with the qualification" do
      expect(build_course_with_qualification_request).to have_been_made.at_least_once
    end
=======
  context 'Selecting QTS' do
    let(:next_step_page) do
      PageObjects::Page::Organisations::Courses::NewApprenticeshipPage.new
    end
    let(:selected_fields) { { qualification: 'qts' } }
    let(:build_course_with_selected_value_request) { stub_api_v2_build_course(qualification: 'qts') }

    before do
      build_course_with_selected_value_request
      choose('course_qualification_qts')
      click_on 'Continue'
    end

    it_behaves_like 'a course creation page'
>>>>>>> 4d86ff8... [2026] Refactor new page tests to shared examples
  end

private

  def visit_new_outcome_page
    visit "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}" \
    "/courses/outcome/new"
  end
end
