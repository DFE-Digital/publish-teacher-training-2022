require 'rails_helper'

feature 'Recruitment cycles', type: :feature do
  let(:provider) { jsonapi :provider, provider_code: 'A6' }
  let(:recruitment_cycle_page) { PageObjects::Page::Organisations::RecruitmentCycle.new }

  before do
    stub_omniauth
    stub_api_v2_request("/providers/#{provider.provider_code}", provider.render)
  end

  context 'during a rollover period' do
    before do
      allow(Settings).to receive(:rollover).and_return(true)
      allow(Settings).to receive(:current_cycle).and_return(2019)
    end

    context 'the current cycle page' do
      let(:year) { 2019 }

      before do
        recruitment_cycle_page.load(provider_code: provider.provider_code, recruitment_cycle_year: year)
      end

      it 'shows the current cycle' do
        expect(recruitment_cycle_page.title).to have_content('Current cycle')
        expect(recruitment_cycle_page).to have_link('Locations', href: "/organisations/#{provider.provider_code}/#{year}/locations")
        expect(recruitment_cycle_page).to have_link('Courses',   href: "/organisations/#{provider.provider_code}/#{year}/courses")
      end
    end

    context 'the next cycle page' do
      let(:year) { 2020 }

      before do
        recruitment_cycle_page.load(provider_code: provider.provider_code, recruitment_cycle_year: year)
      end

      it 'shows the next cycle' do
        expect(recruitment_cycle_page.title).to have_content('Next cycle')
        expect(recruitment_cycle_page).to have_link('Locations', href: "/organisations/#{provider.provider_code}/#{year}/locations")
        expect(recruitment_cycle_page).to have_link('Courses',   href: "/organisations/#{provider.provider_code}/#{year}/courses")
      end
    end
  end
end
