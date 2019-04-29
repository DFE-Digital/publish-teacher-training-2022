require 'rails_helper'

describe UsersController, type: :controller do
  let(:user) { jsonapi :user }

  before do
    stub_omniauth
    stub_session_create
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return('user_id' => user.id)
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
        expect { get :accept_transition_info }.to raise_error JsonApiClient::Errors::ServerError
        expect(Raven).to have_received(:capture_exception).with(instance_of(JsonApiClient::Errors::ServerError))
      end
    end
  end
end
