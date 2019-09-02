require "rails_helper"

feature 'new course outcome', type: :feature do
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:new_entry_requirements_page) do
    PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new
  end
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider, gcse_subjects_required_using_level: true)
    stub_api_v2_new_resource(new_course)
  end

  context 'Selecting QTS' do
    before do
      visit "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}" \
      "/courses/outcome/new"

      choose('course_qualification_qts')
      click_on 'Continue'
    end

    scenario "sends user to entry requirements" do
      expect(new_entry_requirements_page).to be_displayed(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year
      )
    end

    scenario "stores the qualification in the URL" do
      expect(new_entry_requirements_page.url_matches['query']).to eq('course[qualification]' => 'qts')
    end
  end
end
