require "rails_helper"

feature "New course level", type: :feature do
  let(:new_outcome_page) do
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
  end

  scenario "sends user to entry requirements" do
    visit "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}" \
    "/courses/level/new"

    choose "Secondary"
    click_on "Continue"

    expect(current_path).to eq new_provider_recruitment_cycle_courses_entry_requirements_path(provider.provider_code, provider.recruitment_cycle_year)
  end
end
