require "rails_helper"

describe "Sessions", type: :request do
  describe "GET signout" do
    it "redirects to DfE Sign-In session end" do
      stub_omniauth
      get(auth_dfe_callback_path)

      get(signout_path)
      expect(response).to(
        redirect_to(
          "#{Settings.dfe_signin.issuer}/session/end?id_token_hint=&post_logout_redirect_uri=https%3A%2F%2Flocalhost%3A3000%2Fauth%2Fdfe%2Fsignout",
        ),
      )
    end

    context "user session is not present" do
      it "redirects to root path" do
        get(signout_path)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET create_by_magic", feature_signin_by_email: true do
    let(:user) { build :user }
    let(:recruitment_cycle) { build :recruitment_cycle }
    let(:create_by_magic) do
      stub_api_v2_request(
        "/sessions/create_by_magic?magic_link_token=#{token}",
        user.to_jsonapi,
        :patch,
      )
    end

    before do
      create_by_magic
      stub_api_v2_empty_resource_collection(recruitment_cycle, "providers")
    end

    context "valid user and token" do
      let(:email) { user.email }
      let(:token) { SecureRandom.uuid }
      let(:request_path) do
        "#{signin_with_magic_link_path}?email=#{email}&token=#{token}"
      end

      it "returns redirects to root" do
        get request_path

        expect(response).to redirect_to("/")
      end

      it "creates a session with the API" do
        get request_path

        expect(create_by_magic).to have_been_requested
      end

      it "sets the auth_user in the session" do
        get request_path

        expect(session[:auth_user]).to be_present
        expect(session[:auth_user][:info][:email]).to eq email
      end
    end

    describe "sign out" do
      let(:email) { user.email }
      let(:token) { SecureRandom.uuid }

      it "destroys the session" do
        get signout_path

        expect(session[:auth_user]).to_not be_present
      end
    end
  end
end
