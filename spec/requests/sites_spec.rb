require 'rails_helper'

describe 'Sites' do
  let(:site) { jsonapi(:site, location_name: 'Main site 1') }
  let(:provider) { jsonapi(:provider, sites: [site]) }

  before do
    stub_omniauth
    get(auth_dfe_callback_path)
  end

  describe 'GET index' do
    it 'redirects to /2019/locations' do
      get("/organisations/#{provider.provider_code}/locations")
      expect(response).to redirect_to(provider_recruitment_cycle_sites_path(provider.provider_code, site.recruitment_cycle_year))
    end
  end

  describe 'GET new' do
    it 'redirects to /2019/locations/new' do
      get("/organisations/#{provider.provider_code}/locations/new")
      expect(response).to redirect_to(new_provider_recruitment_cycle_site_path(provider.provider_code, site.recruitment_cycle_year))
    end
  end

  describe 'GET edit' do
    it 'redirects to /2019/location/:site_id/edit' do
      get("/organisations/#{provider.provider_code}/locations/#{site.id}/edit")
      expect(response).to redirect_to(edit_provider_recruitment_cycle_site_path(provider.provider_code, site.recruitment_cycle_year, site.id))
    end
  end
end
