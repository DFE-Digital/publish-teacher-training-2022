require "rails_helper"

describe "authorisation", type: :request do
  context "authorised_user defined in settings" do
    let(:user) { build(:user, password: password) }
    let(:password) { "password" }
    let(:provider) { build :provider }
    let(:recruitment_cycle) { build :recruitment_cycle }
    let(:headers) { {} }

    before do
      stub_api_v2_resource(recruitment_cycle)
      stub_api_v2_resource_collection([provider])
      stub_api_v2_resource(provider)
    end

    context "basic http authenticated" do
      let(:headers) do
        {
          "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic
                                    .encode_credentials(user.email, password),
        }
      end

      it "considers the user logged in" do
        stub_authorised_development_user(user) do
          get "/organisations/#{provider.provider_code}", headers: headers
        end

        expect(response).to be_successful
      end
    end

    context "without basic http authentication" do
      it "requests user login" do
        stub_authorised_development_user(user) do
          get "/organisations/#{provider.provider_code}", headers: headers
        end

        expect(response).to be_unauthorized
      end
    end
  end

  describe "/send_magic_link" do
    context "with the signin_by_email feature enabled", feature_signin_by_email: true do
      it "makes a request to the api to send the magic link" do
        api_stub = stub_api_v2_request(
          "/users/generate_and_send_magic_link",
          "",
          :patch,
        )
        email = "logmein@localhost"

        post "/send_magic_link", params: { user: { email: email } }

        expected_token = JWT.encode(
          { email: email },
          Settings.manage_backend.secret,
          Settings.manage_backend.algorithm,
        )

        expect(api_stub).to have_been_requested
        expect(api_stub.with(
                 headers: { "Authorization" => "Bearer #{expected_token}" },
               )).to have_been_made
      end

      it "makes redirects to the magic_link_sent page" do
        stub_api_v2_request(
          "/users/generate_and_send_magic_link",
          "",
          :patch,
        )
        email = "logmein@localhost"

        post "/send_magic_link", params: { user: { email: email } }

        expect(response).to redirect_to magic_link_sent_path
      end
    end

    context "with the signin_by_email feature disabled", feature_signin_by_email: false do
      it "returns an error" do
        email = "logmein@localhost"

        expect {
          post "/send_magic_link", params: { user: { email: email } }
        }.to raise_error RuntimeError, "Feature signin_by_email is disabled"
      end
    end
  end

  describe "/magic_link_sent" do
    it "renders the view" do
      get "/magic_link_sent"

      expect(response).to render_template(:magic_link_sent)
    end
  end
end
