require "rails_helper"

feature 'new course apprenticeship', type: :feature do
  let(:new_apprenticeship_page) do
    PageObjects::Page::Organisations::Courses::NewApprenticeshipPage.new
  end
  let(:provider) { build(:provider) }
  let(:recruitment_cycle) { build(:recruitment_cycle) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider)
    stub_api_v2_new_resource(new_course)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([new_course], include: "sites,provider.sites,accrediting_provider")
  end

  scenario "sends user to entry requirements" do
    visit new_provider_recruitment_cycle_courses_apprenticeship_path(provider.provider_code, provider.recruitment_cycle_year)

    choose('course_program_type_higher_education_programme')
    click_on 'Continue'

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end
end
