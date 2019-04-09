require 'rails_helper'

feature 'Edit locations', type: :feature do
  let(:site) { jsonapi(:site, location_name: 'Main site 1') }

  let(:provider) do
    jsonapi(:provider, sites: [site]).render
  end

  let(:provider_attributes) { provider[:data][:attributes] }

  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request("/providers/#{provider_attributes[:provider_code]}?include=sites", provider)
  end

  scenario 'it shows a location' do
    visit provider_site_path(provider_attributes[:provider_code], site.id)

    expect(find('h1')).to have_content('Main site 1')
  end
end
