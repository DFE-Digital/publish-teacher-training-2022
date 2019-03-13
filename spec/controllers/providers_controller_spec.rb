require 'rails_helper'

RSpec.describe ProvidersController, type: :controller do
  context "with authenticated user" do
    before do
      stub_omniauth
      stub_session_create
    end

    describe 'GET #index' do
      context 'with providers' do
        before do
          stub_api_v2_request('/providers', build(:providers_response))
        end

        it 'returns the index page' do
          get :index
          expect(response).to have_http_status(:success)
        end
      end

      context 'without any providers' do
        before do
          stub_api_v2_request('/providers', build(:providers_response, data: []))
        end

        it 'redirects to manage-courses-ui' do
          get :index
          expect(response).to redirect_to(Settings.manage_ui.base_url)
        end
      end
    end
  end
end
