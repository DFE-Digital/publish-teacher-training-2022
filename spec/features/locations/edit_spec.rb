require 'rails_helper'

feature 'Edit locations', type: :feature do
  let(:site) { jsonapi(:site, location_name: 'Main site 1') }

  let(:provider) do
    jsonapi(:provider, sites: [site]).render
  end

  let(:provider_attributes) { provider[:data][:attributes] }
  let(:provider_code) { provider_attributes[:provider_code] }
  let(:locations_page) { PageObjects::Page::LocationsPage.new }
  let(:location_page) { PageObjects::Page::LocationPage.new }

  describe "without errors" do
    before do
      stub_omniauth
      stub_session_create
      stub_api_v2_request("/providers/#{provider_code}?include=sites", provider)
      stub_api_v2_request("/providers/#{provider_code}/sites/#{site.id}", site, :patch, 200)
    end

    scenario 'it shows a location' do
      visit edit_provider_site_path(provider_code, site.id)

      expect(location_page).to be_displayed(provider_code: provider_code, site_id: site.id)
      expect(location_page.title).to have_content('Main site 1')

      location_page.publish_changes.click

      expect(locations_page).to be_displayed
      expect(locations_page.success_summary).to have_content('Your changes have been published')
    end
  end

  describe "with validations errors" do
    before do
      stub_omniauth
      stub_session_create
      stub_api_v2_request("/providers/#{provider_code}?include=sites", provider)
      stub_api_v2_request("/providers/#{provider_code}/sites/#{site.id}", build(:error), :patch, 422)
    end

    scenario 'displays validation errors' do
      visit edit_provider_site_path(provider_code, site.id)

      expect(location_page).to be_displayed(provider_code: provider_code, site_id: site.id)

      location_page.publish_changes.click

      expect(location_page).to be_displayed(provider_code: provider_code, site_id: site.id)
      expect(location_page.error_summary).to have_content('Name is missing')
    end

    scenario 'displays the old location name when the change fails' do
      visit edit_provider_site_path(provider_code, site.id)

      expect(location_page.title).to have_content('Main site 1')

      location_page.name_field.set "Main site 2"
      location_page.publish_changes.click

      expect(location_page.title).to have_content('Main site 1')
    end
  end
end
