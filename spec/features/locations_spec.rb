require 'rails_helper'

feature 'Index locations', type: :feature do
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

  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request("/providers/#{provider_attributes[:institution_code]}?include=sites", provider)
    visit provider_sites_path(provider_attributes[:institution_code])
  end

  scenario 'it shows a list of location' do
    expect(find('h1')).to have_content('Locations')
    expect(page).to have_selector('tbody tr', count: 3)
    expect(first('.govuk-table__cell')).to have_content('Main site 1')
    expect(page).to_not have_link('Add a location')
  end

  context 'when the provider is opted_in' do
    let(:provider) do
      jsonapi(:provider, :opted_in, sites: sites).render
    end

    scenario 'should show Add Location CTA' do
      expect(page).to have_link('Add a location')
    end
  end
end
