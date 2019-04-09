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
  let(:site_response) { sites[0].render }

  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request("/providers/#{provider_attributes[:provider_code]}?include=sites", provider)
  end

  scenario 'it shows a list of locations' do
    visit provider_sites_path(provider_attributes[:provider_code])

    expect(find('h1')).to have_content('Locations')
    expect(page).to have_selector('tbody tr', count: 3)
    expect(first('.govuk-table__cell')).to_not have_link('Main site 1')
    expect(first('.govuk-table__cell')).to have_content('Main site 1')
    expect(page).to_not have_link('Add a location')
  end

  scenario 'it shows one location' do
    stub_api_v2_request("/providers/#{provider_attributes[:provider_code]}/sites/#{sites[0].id}", site_response)

    visit("/organisations/#{provider_attributes[:provider_code]}/locations/#{sites[0].id}/edit")

    expect(find('h1')).to have_content('Main site 1')
  end

  context 'when the provider is opted_in' do
    let(:provider) do
      jsonapi(:provider, :opted_in, sites: sites).render
    end

    scenario 'should show Add Location CTA' do
      visit provider_sites_path(provider_attributes[:provider_code])

      expect(first('.govuk-table__cell')).to have_link('Main site 1')
      expect(page).to have_link('Add a location')
    end
  end
end
