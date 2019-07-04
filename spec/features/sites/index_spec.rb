require 'rails_helper'

feature 'View locations', type: :feature do
  let(:sites) do
    [
      jsonapi(:site, location_name: 'Main site 1'),
      jsonapi(:site, location_name: 'Main site 2'),
      jsonapi(:site, location_name: 'Main site 3')
    ]
  end

  let(:provider) do
    jsonapi(:provider, sites: sites).render
  end
  let(:provider_attributes) { provider[:data][:attributes] }
  let(:provider_code) { provider_attributes[:provider_code] }
  let(:site_response) { sites[0].render }
  let(:root_page) { PageObjects::Page::RootPage.new }
  let(:organisation_page) { PageObjects::Page::Organisations::OrganisationPage.new }
  let(:locations_page) { PageObjects::Page::LocationsPage.new }
  let(:location_page) { PageObjects::Page::LocationPage.new }

  before do
    allow(Settings).to receive(:rollover).and_return(false)
    user = build(:user)
    stub_omniauth(user: user)
    stub_api_v2_request('/providers', jsonapi(:providers_response, data: [provider[:data]]))
    stub_api_v2_request("/providers/#{provider_code}", provider)
    stub_api_v2_request("/providers/#{provider_code}?include=sites", provider)

    root_page.load
    expect(organisation_page).to be_displayed(provider_code: provider_code)
    organisation_page.locations.click
  end

  scenario 'it shows a list of locations' do
    expect(locations_page).to be_displayed(provider_code: provider_code)
    expect(locations_page.title).to have_content('Locations')
    expect(locations_page.locations.size).to eq(3)
    expect(locations_page.locations.first).to have_link
    expect(locations_page.locations.first.cell.text).to eq('Main site 1')
    expect(locations_page).to have_add_a_location_link
  end

  scenario 'it shows one location' do
    stub_api_v2_request("/providers/#{provider_code}/sites/#{sites.first.id}", site_response)

    expect(locations_page.locations.first).to have_link
    locations_page.locations.first.link.click

    expect(location_page).to be_displayed(provider_code: provider_code, site_id: sites[0].id)
    expect(location_page.title).to have_content('Main site 1')
  end

  scenario 'prompts users to add new locations' do
    expect(locations_page).to have_add_a_location_link
  end

  context 'rollover' do
    it 'it shows a list of locations' do
      allow(Settings).to receive(:rollover).and_return(true)
      root_page.load
      expect(organisation_page).to be_displayed(provider_code: provider_code)
      organisation_page.current_cycle.click
      organisation_page.locations.click

      expect(locations_page).to be_displayed(provider_code: provider_code)
      expect(locations_page.title).to have_content('Locations')
      expect(locations_page.locations.size).to eq(3)
    end
  end
end
