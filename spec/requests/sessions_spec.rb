require "rails_helper"

describe "Sessions", type: :request do
  describe "GET signout" do
    it "redirects to DfE Sign-In session end" do
      stub_omniauth
      get(auth_dfe_callback_path)

      get(signout_path)
      expect(response).to redirect_to(
                            "#{Settings.dfe_signin.issuer}/session/end?id_token_hint=&post_logout_redirect_uri=https%3A%2F%2Flocalhost%3A3000%2Fauth%2Fdfe%2Fsignout"
                          )
    end

    context "user session is not present" do
      it "redirects to root path" do
        get(signout_path)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
