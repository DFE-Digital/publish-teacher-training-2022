require 'rails_helper'

describe UsersController, type: :controller do
  let(:user) { build :user }

  before do
    stub_omniauth(user: user)

    # TODO: This is ugly, but will be removed when controller specs are axed.
    old_controller = @controller
    @controller = SessionsController.new
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:dfe]
    get :create
    @controller = old_controller

    allow(Raven).to receive(:capture_exception)
  end

  describe 'GET #accept_transition_info' do
    context "with working request" do
      before do
        stub_api_v2_request("/users/#{user.id}/accept_transition_screen", {}, :patch, 200)
      end

      it "redirects to providers index" do
        get :accept_transition_info
        expect(response).to redirect_to(providers_path)
      end
    end

    context "with client error" do
      before do
        stub_api_v2_request("/users/#{user.id}/accept_transition_screen", {}, :patch, 400)
      end

      it "redirects to providers index" do
        get :accept_transition_info
        expect(Raven).to have_received(:capture_exception).with(instance_of(JsonApiClient::Errors::ClientError))
        expect(response).to redirect_to(providers_path)
      end
    end

    context "with server error" do
      before do
        stub_api_v2_request("/users/#{user.id}/accept_transition_screen", {}, :patch, 500)
      end

      it "redirects to providers index" do
        get :accept_transition_info
        expect(Raven).to have_received(:capture_exception).with(instance_of(JsonApiClient::Errors::ServerError))
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
