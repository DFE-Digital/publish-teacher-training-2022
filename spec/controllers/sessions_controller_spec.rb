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
