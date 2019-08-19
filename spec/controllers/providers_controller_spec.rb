require 'rails_helper'

RSpec.describe ProvidersController, type: :controller do
  context "with authenticated user" do
    before do
      stub_omniauth

      # TODO: This is ugly, but will be removed when controller specs are axed.
      old_controller = @controller
      @controller = SessionsController.new
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:dfe]
      get :create
      @controller = old_controller
    end

    before do
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}",
        current_recruitment_cycle.to_jsonapi
      )
    end

    describe 'GET #index' do
      context 'with 2 or more providers' do
        let(:current_recruitment_cycle) { build(:recruitment_cycle) }

        let(:providers) do
          [
            build(:provider, courses: [build(:course)]),
            build(:provider, courses: [build(:course)]),
            build(:provider, courses: [build(:course)])
          ]
        end

        let(:providers_response) do
          resource_list_to_jsonapi(providers)
        end

        before do
          stub_api_v2_request(
            "/recruitment_cycles/#{current_recruitment_cycle.year}",
            current_recruitment_cycle.to_jsonapi
          )
          stub_api_v2_request(
            "/recruitment_cycles/#{current_recruitment_cycle.year}/providers",
            providers_response
          )
        end

        it 'returns the index page' do
          get :index
          expect(response).to have_http_status(:success)
        end
      end

      context 'with 1 provider' do
        let(:provider) { build(:provider) }
        let(:current_recruitment_cycle) { build(:recruitment_cycle) }

        before do
          stub_api_v2_request(
            "/recruitment_cycles/#{current_recruitment_cycle.year}/providers",
            provider.to_jsonapi
          )
        end

        it 'returns the show page' do
          get :index
          expect(response).to redirect_to(action: :show, code: provider.provider_code)
        end
      end

      context 'with 0 providers' do
        let(:providers_response) { nil }
        let(:current_recruitment_cycle) { build(:recruitment_cycle) }

        before do
          stub_api_v2_request(
            "/recruitment_cycles/#{current_recruitment_cycle.year}/providers",
            providers_response
          )
        end

        it 'redirects to manage-courses-ui' do
          get :index
          expect(response).to redirect_to(unauthorized_path)
        end
      end
    end
  end
end
