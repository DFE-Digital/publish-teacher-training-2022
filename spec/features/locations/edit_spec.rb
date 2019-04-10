require 'rails_helper'

feature 'Edit locations', type: :feature do
  let(:site) { jsonapi(:site, location_name: 'Main site 1') }

  let(:provider) do
    jsonapi(:provider, sites: [site]).render
  end

  let(:provider_attributes) { provider[:data][:attributes] }

  describe "without errors" do
    before do
      stub_omniauth
      stub_session_create
      stub_api_v2_request("/providers/#{provider_attributes[:provider_code]}?include=sites", provider)
      stub_api_v2_request("/providers/#{provider_attributes[:provider_code]}/sites/#{site.id}", site, :patch, 200)
    end

    scenario 'it shows a location' do
      visit edit_provider_site_path(provider_attributes[:provider_code], site.id)

      expect(find('h1')).to have_content('Main site 1')

      click_on('Publish changes')

      expect(find('h1')).to have_content('Locations')
      expect(find('.govuk-success-summary')).to have_content('Your changes have been published')
    end
  end

  describe "with validations errors" do
    before do
      stub_omniauth
      stub_session_create
      stub_api_v2_request("/providers/#{provider_attributes[:provider_code]}?include=sites", provider)
      stub_api_v2_request("/providers/#{provider_attributes[:provider_code]}/sites/#{site.id}", build(:error), :patch, 422)
    end

    scenario 'displays validation errors' do
      visit edit_provider_site_path(provider_attributes[:provider_code], site.id)

      expect(find('h1')).to have_content('Main site 1')

      click_on('Publish changes')

      expect(find('h1')).to have_content('Main site 1')
      expect(find('.govuk-error-summary')).to have_content('Name is missing')
    end
  end
end
