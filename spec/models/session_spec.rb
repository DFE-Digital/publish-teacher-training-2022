require "rails_helper"

describe Session do
  describe ".create_by_magic" do
    let(:user) { build :user }
    let(:session_stub) do
      stub_api_v2_request("/sessions/create_by_magic?magic_link_token=magic-token", user.to_jsonapi, :patch)
    end
    let(:payload) { { email: user.email } }
    let(:expected_token) { "expected_token" }

    before(:each) do
      session_stub
      allow(JWT::EncodeService).to receive(:call)
        .with(payload: payload)
        .and_return(expected_token)

      Session.create_by_magic(
        magic_link_token: "magic-token",
        email: user.email,
      )
    end

    it "makes a PATCH request to the API" do
      expect(session_stub).to have_been_requested
    end

    it "sends the Authorization header" do
      expect(session_stub.with(
               headers: { "Authorization" => "Bearer #{expected_token}" },
             )).to have_been_made
    end

    it "has performed jwt encoding service" do
      expect(JWT::EncodeService).to have_received(:call)
    end
  end
end
