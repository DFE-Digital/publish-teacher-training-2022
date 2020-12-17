require "rails_helper"

describe "authorisation", type: :request do
  describe "basic auth" do
    before do
      allow(Settings.authentication).to receive(:mode)
      .and_return(mode)
    end

    context "when mode is persona" do
      let(:mode) { "persona" }

      before do
        allow(Settings.authentication.basic_auth).to receive(:disabled)
        .and_return(disabled)
      end

      context "when disabled is false" do
        let(:disabled) { false }

        context "with correct details" do
          let(:headers) do
            {
              "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic
                                        .encode_credentials("admin", "secret"),
            }
          end

          it "grants access" do
            expect(Digest::SHA512).to receive(:hexdigest).with("secret").and_return("52785638ec464fd61f5c9b372797f1a7475225cabeb2b40b2d757eff9b337ff069b2314bb0c0611d44ca5d39c91906ab3415de0fbc36625b970e3c2c03d122da").at_least(:once)

            get "/", headers: headers
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
            get "/", headers: headers

            expect(response).to have_http_status(401)
          end
        end
      end

      context "when disabled is true" do
        let(:disabled) { true }

        it "redirects to sign-in page" do
          get "/"
          expect(response).to redirect_to(sign_in_path)
        end
      end
    end

    context "when mode is dfe_signin" do
      let(:mode) { "dfe_signin" }

      it "redirects to sign-in page" do
        get "/"
        expect(response).to redirect_to(sign_in_path)
      end
    end

    context "when mode is magic" do
      let(:mode) { "magic" }

      it "redirects to sign-in page" do
        get "/"
        expect(response).to redirect_to(sign_in_path)
      end
    end
  end

  describe "/send_magic_link" do
    let(:email) { "logmein@localhost" }
    let(:payload) { { email: email } }
    let(:expected_token) { "expected_token" }
    let(:stub_api_request) do
      stub_api_v2_request(
        "/users/generate_and_send_magic_link",
        "",
        :patch,
      )
    end

    before do
      allow(JWT::EncodeService).to receive(:call)
        .with(payload: payload)
        .and_return(expected_token)
    end

    context "with the signin_by_email feature enabled", feature_signin_by_email: true do
      it "makes a request to the api to send the magic link" do
        api_stub = stub_api_request

        post "/send_magic_link", params: { user: { email: email } }

        expect(JWT::EncodeService).to have_received(:call)
        expect(api_stub).to have_been_requested
        expect(api_stub.with(
                 headers: { "Authorization" => "Bearer #{expected_token}" },
               )).to have_been_made
      end

      it "makes redirects to the magic_link_sent page" do
        stub_api_request

        post "/send_magic_link", params: { user: { email: email } }
        expect(JWT::EncodeService).to have_received(:call)
        expect(response).to redirect_to magic_link_sent_path
      end
    end

    context "with the signin_by_email feature disabled", feature_signin_by_email: false do
      it "returns an error" do
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
