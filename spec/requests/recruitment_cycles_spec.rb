require 'rails_helper'

describe 'Recruitment cycles' do
  before do
    stub_omniauth
    get(auth_dfe_callback_path)
  end

  describe 'GET show' do
    it 'redirects to the course index page' do
      provider = jsonapi(:provider)
      stub_api_v2_request("/providers/#{provider.provider_code}", provider.render)
      allow(Settings).to receive(:rollover).and_return(false)

      get("/organisations/#{provider.provider_code}/2019")
      expect(response).to redirect_to(provider_path(provider.provider_code))

      get("/organisations/#{provider.provider_code}/2020")
      expect(response).to redirect_to(provider_path(provider.provider_code))
    end

    context 'rollover' do
      it 'renders the recruitment cycle page' do
        provider = jsonapi(:provider)
        stub_api_v2_request("/providers/#{provider.provider_code}", provider.render)
        allow(Settings).to receive(:rollover).and_return(true)

        get("/organisations/#{provider.provider_code}/2019")
        expect(response.body).to include('Current cycle (2019 – 2020)')
      end
    end
  end
end
