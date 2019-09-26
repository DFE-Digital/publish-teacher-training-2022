require "rails_helper"

feature "Recruitment cycles", type: :feature do
  let(:previous_recruitment_cycle) { build :recruitment_cycle, :previous_cycle }
  let(:provider) { build :provider, provider_code: "A6" }
  let(:recruitment_cycle_page) { PageObjects::Page::Organisations::RecruitmentCycle.new }

  before do
    stub_omniauth
    stub_api_v2_request("/recruitment_cycles/#{previous_recruitment_cycle.year}", previous_recruitment_cycle.to_jsonapi)
    stub_api_v2_request("/recruitment_cycles/#{previous_recruitment_cycle.year}/providers/#{provider.provider_code}", provider.to_jsonapi)
  end

  context "previous cycle" do
    let(:year) { previous_recruitment_cycle.year }

    before do
      recruitment_cycle_page.load(provider_code: provider.provider_code, recruitment_cycle_year: year)
    end

    it "shows the previous cycle" do
      expect(recruitment_cycle_page.title).to have_content("Previous cycle")
      expect(recruitment_cycle_page).to have_link("About your organisation", href: "/organisations/#{provider.provider_code}/#{year}/details")
      expect(recruitment_cycle_page).to have_link("Courses", href: "/organisations/#{provider.provider_code}/#{year}/courses")
      expect(recruitment_cycle_page).to have_link("Locations", href: "/organisations/#{provider.provider_code}/#{year}/locations")
    end
  end
end
