require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  describe "GET signout" do
    it "redirects the user to DfE Sign-in's session end endpoint" do
      @request.session["auth_user"] = {
        "credentials" => {
          "id_token" => "123"
        }
      }

      get :signout

      expect(subject).to redirect_to("https://signin-test-oidc-as.azurewebsites.net/session/end?id_token_hint=123&post_logout_redirect_uri=https://localhost:3000/auth/dfe/signout")
    end
  end

  describe "GET create" do
    user_info = {
      "first_name" => "John",
      "last_name" => "Smith",
      "email" => "email@example.com"
    }

    user_id = 101
    before do
      allow(Session).to receive(:create)
        .with(first_name: user_info[:first_name], last_name: user_info[:last_name])
        .and_return(double(id: user_id))
    end

    it "creates the session and redirects to root" do
      @request.env["omniauth.auth"] = {
        "info" => user_info
      }

      get :create

      expect(subject).to redirect_to("/")
      expect(@request.session[:auth_user][:user_id]).to eq user_id
      expect(@request.session[:auth_user]["info"]).to eq user_info
    end
  end

  describe "GET destroy" do
    it "destroys the session and redirects to root" do
      @request.session["auth_user"] = {
        "credentials" => {
          "id_token" => "123"
        }
      }

      get :destroy

      expect(subject).to redirect_to("/")
      expect(@request.session).to be_empty
    end
  end

  # Omniauth documentation says that any authentication failure with the provider
  # will be caught and routed to /auth/failure: https://github.com/omniauth/omniauth/wiki
  describe "GET failure" do
    it "redirects to a 401 page" do
      get :failure

      expect(response.status).to redirect_to("/401")
    end
  end
end
