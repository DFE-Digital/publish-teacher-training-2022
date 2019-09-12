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
    allow(Settings).to receive(:rollover).and_return(true)
  end

  describe 'GET #accept_transition_info' do
    context "with working request" do
      before do
        stub_api_v2_request("/users/#{user.id}/accept_transition_screen", {}, :patch, 200)
      end

      it "redirects to the rollover screen" do
        get :accept_transition_info
        expect(response).to redirect_to(rollover_path)
      end
    end

    context "with client error" do
      before do
        stub_api_v2_request("/users/#{user.id}/accept_transition_screen", {}, :patch, 400)
      end

      it "redirects to rollover screen" do
        get :accept_transition_info
        expect(Raven).to have_received(:capture_exception).with(instance_of(JsonApiClient::Errors::ClientError))
        expect(response).to redirect_to(rollover_path)
      end
    end
  end

  describe 'GET #accept_transition_info when rollover is disabled' do
    before do
      allow(Settings).to receive(:rollover).and_return(false)
    end

    context "with working request" do
      before do
        stub_api_v2_request("/users/#{user.id}/accept_transition_screen", {}, :patch, 200)
      end

      it "redirects to the providers screen" do
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
  end

  describe 'GET #accept_rollover' do
    context "with working request" do
      before do
        stub_api_v2_request("/users/#{user.id}/accept_rollover_screen", {}, :patch, 200)
      end

      it "redirects to providers index" do
        get :accept_rollover
        expect(response).to redirect_to(providers_path)
      end
    end

    context "with client error" do
      before do
        stub_api_v2_request("/users/#{user.id}/accept_rollover_screen", {}, :patch, 400)
      end

      it "redirects to providers index" do
        get :accept_rollover
        expect(Raven).to have_received(:capture_exception).with(instance_of(JsonApiClient::Errors::ClientError))
        expect(response).to redirect_to(providers_path)
      end
    end
  end

  describe 'GET #accept_terms' do
    context "with working request" do
      before do
        stub_api_v2_request("/users/#{user.id}/accept_terms", {}, :patch, 200)
      end

      it "redirects to providers index" do
        get :accept_terms, params: { user: { terms_accepted: "1" } }
        expect(response).to redirect_to(providers_path)
      end
    end

    context "with client error" do
      before do
        stub_api_v2_request("/users/#{user.id}/accept_terms", {}, :patch, 400)
      end

      it "redirects to providers index" do
        get :accept_terms, params: { user: { terms_accepted: "1" } }
        expect(Raven).to have_received(:capture_exception).with(instance_of(JsonApiClient::Errors::ClientError))
        expect(response).to redirect_to(providers_path)
      end
    end
  end
end
