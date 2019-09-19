require "rails_helper"

feature 'New course level', type: :feature do
  let(:new_level_page) do
    PageObjects::Page::Organisations::Courses::NewLevelPage.new
  end
  let(:provider) { build(:provider) }
  let(:course) { build(:course, :new, provider: provider, gcse_subjects_required_using_level: true) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_new_resource(course)
    stub_api_v2_build_course
    stub_api_v2_build_course(is_send: 0, level: "secondary")

    visit "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}" \
    "/courses/level/new"
  end

  scenario "sends user to entry requirements" do
    choose "Secondary"
    click_on "Continue"

    expect(current_path).to eq new_provider_recruitment_cycle_courses_outcome_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  context 'Selecting primary' do
    let(:next_step_page) do
      PageObjects::Page::Organisations::Courses::NewOutcomePage.new
    end
    let(:selected_fields) { { level: 'primary', is_send: '0' } }
    let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

    before do
      build_course_with_selected_value_request
      new_level_page.level_fields.primary.click
      new_level_page.continue.click
    end

    it_behaves_like 'a course creation page'
  end
end
