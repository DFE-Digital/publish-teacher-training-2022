require 'rails_helper'

describe 'Providers', type: :request do
  before do
    stub_omniauth
    stub_session_create
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
