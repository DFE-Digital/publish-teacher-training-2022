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
end
