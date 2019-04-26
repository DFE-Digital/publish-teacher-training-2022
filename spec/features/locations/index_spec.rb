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
    user = jsonapi :user, :opted_in
    stub_omniauth(disable_completely: false, user: user)
    stub_session_create(user: User.new(JSON.parse(user.to_json)))
    stub_api_v2_request('/providers', jsonapi(:providers_response, data: [provider[:data]]))
    stub_api_v2_request("/providers/#{provider_attributes[:provider_code]}", provider)
    stub_api_v2_request("/providers/#{provider_attributes[:provider_code]}?include=sites", provider)

    visit "/"
    click_on "Locations"
  end

  scenario 'it shows a list of locations' do
    expect(find('h1')).to have_content('Locations')
    expect(page).to have_selector('tbody tr', count: 3)
    expect(first('.govuk-table__cell')).to_not have_link('Main site 1')
    expect(first('.govuk-table__cell')).to have_content('Main site 1')
    expect(page).to_not have_link('Add a location')
  end

  context 'when the provider is opted_in' do
    let(:provider) do
      jsonapi(:provider, :opted_in, sites: sites).render
    end

    scenario 'it shows one location' do
      stub_api_v2_request("/providers/#{provider_attributes[:provider_code]}/sites/#{sites.first.id}", site_response)

      click_on "Main site 1"

      expect(find('h1')).to have_content('Main site 1')
    end

    scenario 'should show Add Location CTA' do
      expect(first('.govuk-table__cell')).to have_link('Main site 1')
      expect(page).to have_link('Add a location', href: /#{Settings.google_forms.add_location.url.gsub('?', '\?')}/)
    end
  end
end
