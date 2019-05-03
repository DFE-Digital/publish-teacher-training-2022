require 'rails_helper'

describe 'Providers', type: :request do
  before do
    stub_omniauth
    get(auth_dfe_callback_path)
  end

  describe 'GET index' do
    context 'with 1 provider' do
      it 'redirects to providers show' do
        provider = jsonapi(:provider)
        stub_api_v2_request('/providers', provider.render)
        get(providers_path)
        expect(response).to redirect_to provider_path(provider.provider_code)
      end
    end

    context 'with 2 or more providers' do
      it 'renders providers index' do
        provider1 = jsonapi(:provider, include_counts: [:courses])
        provider2 = jsonapi(:provider, include_counts: [:courses])
        providers = jsonapi(:providers_response, data: [provider1.render[:data], provider2.render[:data]])
        stub_api_v2_request('/providers', providers)
        get(providers_path)
        expect(response.body).to include('Organisations')
        expect(response.body).to include(provider1.provider_name)
      end
    end

    context 'user has no providers' do
      it 'redirects to manage-courses-ui' do
        stub_api_v2_request('/providers', jsonapi(:providers_response, data: []))
        get(providers_path)
        expect(response).to redirect_to(Settings.manage_ui.base_url)
      end
    end
  end

  describe 'GET show' do
    it 'render providers show' do
      provider = jsonapi(:provider)
      stub_api_v2_request("/providers/#{provider.provider_code}", provider.render)
      get(provider_path(provider.provider_code))
      expect(response.body).to include(provider.provider_name)
    end

    context 'provider does not exist' do
      it 'renders not found' do
        stub_api_v2_request("/providers/foo", {}, :get, 404)
        get(provider_path('foo'))
        expect(response.body).to include('Page not found')
      end
    end
  end
end
