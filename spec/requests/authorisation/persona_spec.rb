require "rails_helper"

describe "authorisation", type: :request do
  before do
    allow(Settings.authentication).to receive(:mode)
    .and_return(mode)
  end

  context "when mode is persona" do
    let(:mode) { "persona" }

    describe "basic auth" do
      before do
        allow(Settings.authentication.basic_auth).to receive(:disabled)
        .and_return(disabled)
      end

      context "when basic_auth.disabled is false" do
        let(:disabled) { false }

        context "with correct details" do
          let(:headers) do
            {
              "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic
                                        .encode_credentials("publish", "secret"),
            }
          end

          it "grants access" do
            expect(Digest::SHA512).to receive(:hexdigest).with("secret").and_return("52785638ec464fd61f5c9b372797f1a7475225cabeb2b40b2d757eff9b337ff069b2314bb0c0611d44ca5d39c91906ab3415de0fbc36625b970e3c2c03d122da").at_least(:once)

            get(root_path, headers: headers)
            expect(response).to redirect_to(sign_in_path)
          end
        end

        context "with incorrect details" do
          let(:headers) do
            {
              "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic
                                        .encode_credentials("foo", "bar"),
            }
          end

          it "denys access" do
            get(root_path, headers: headers)

            expect(response).to have_http_status(401)
          end
        end
      end

      context "when basic_auth.disabled is true" do
        let(:disabled) { true }

        it "redirects to sign-in page" do
          get(root_path)
          expect(response).to redirect_to(sign_in_path)
        end
      end
    end
  end
end
