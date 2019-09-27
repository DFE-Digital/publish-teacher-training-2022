require "rails_helper"

feature "Recruitment cycles", type: :feature do
  let(:current_recruitment_cycle) { build :recruitment_cycle, year: "2019" }
  let(:next_recruitment_cycle) { build :recruitment_cycle, year: "2020" }
  let(:provider) { build :provider, provider_code: "A6" }
  let(:recruitment_cycle_page) { PageObjects::Page::Organisations::RecruitmentCycle.new }

  before do
    stub_omniauth
    stub_api_v2_request("/recruitment_cycles/#{next_recruitment_cycle.year}", next_recruitment_cycle.to_jsonapi)
    stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
    stub_api_v2_request("/recruitment_cycles/#{next_recruitment_cycle.year}/providers/#{provider.provider_code}", provider.to_jsonapi)
    stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}", provider.to_jsonapi)
  end

  context "during a rollover period" do
    before do
      allow(Settings).to receive(:rollover).and_return(true)
      allow(Settings).to receive(:current_cycle).and_return(2019)
    end

    context "the current cycle page" do
      let(:year) { 2019 }

      before do
        recruitment_cycle_page.load(provider_code: provider.provider_code, recruitment_cycle_year: year)
      end

      it "shows the current cycle" do
        expect(recruitment_cycle_page.title).to have_content("Current cycle")
        expect(recruitment_cycle_page).to have_link("Locations", href: "/organisations/#{provider.provider_code}/#{year}/locations")
        expect(recruitment_cycle_page).to have_link("Courses",   href: "/organisations/#{provider.provider_code}/#{year}/courses")
        expect(recruitment_cycle_page).to have_link("About your organisation", href: "/organisations/#{provider.provider_code}/#{year}/details")
      end
    end

    context "the next cycle page" do
      let(:year) { 2020 }

      before do
        recruitment_cycle_page.load(provider_code: provider.provider_code, recruitment_cycle_year: year)
      end

      it "shows the next cycle" do
        expect(recruitment_cycle_page.title).to have_content("Next cycle")
        expect(recruitment_cycle_page).to have_link("Locations", href: "/organisations/#{provider.provider_code}/#{year}/locations")
        expect(recruitment_cycle_page).to have_link("Courses",   href: "/organisations/#{provider.provider_code}/#{year}/courses")
        expect(recruitment_cycle_page).to have_link("About your organisation", href: "/organisations/#{provider.provider_code}/#{year}/details")
      end
    end
  end
end
