require "rails_helper"

describe "authorisation", type: :request do
  let(:email) { "logmein@localhost" }

  context "when mode is non_magic", authentication_mode: :non_magic do
    let(:mode) { "non-magic" }

    it "returns an error" do
      post "/send_magic_link", params: { user: { email: email } }
      expect(response.status).to be(404)
    end
  end

  context "when mode is magic", authentication_mode: :magic do
    describe "/send_magic_link" do
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

    describe "/magic_link_sent" do
      it "renders the view" do
        get "/magic_link_sent"

        expect(response).to render_template(:magic_link_sent)
      end
    end
  end
end
