require "rails_helper"

feature "New course level", type: :feature do
  let(:new_subjects_page) do
    PageObjects::Page::Organisations::Courses::NewSubjectsPage.new
  end
  let(:next_step_page) do
    PageObjects::Page::Organisations::Courses::NewAgeRangePage.new
  end
  let(:provider) { build(:provider) }
  let(:english) { build(:subject, :english) }
  let(:biology) { build(:subject, :biology) }
  let(:subjects) { [english, biology] }
  let(:edit_options) { { subjects: subjects, age_range_in_years: [] } }
  let(:course) { build(:course, :new, provider: provider, level: :secondary, gcse_subjects_required_using_level: true, edit_options: edit_options) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_new_resource(course)
    stub_api_v2_build_course
    stub_api_v2_build_course

    visit "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}" \
    "/courses/subjects/new"
  end

  context "Selecting primary" do
    let(:selected_fields) { { subjects_ids: [english.id] } }
    let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

    before do
      build_course_with_selected_value_request
      new_subjects_page.subjects_fields.select(english.subject_name).click
      new_subjects_page.continue.click
    end

    scenario "sends user to new outcome page" do
      expect(next_step_page).to be_displayed
    end

    it_behaves_like "a course creation page"
  end
end
