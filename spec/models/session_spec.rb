require "rails_helper"

describe Session do
  describe ".create_by_magic" do
    let(:user) { build :user }
    let(:session_stub) do
      stub_api_v2_request("/sessions/create_by_magic?magic_link_token=magic-token", user.to_jsonapi, :patch)
    end

    before(:each) do
      session_stub
    end

    it "makes a PATCH request to the API" do
      Session.create_by_magic(
        magic_link_token: "magic-token",
        email: user.email,
      )

      expect(session_stub).to have_been_requested
    end

    it "sends the Authorization header" do
      payload = { email: user.email }
      expected_token = JWT.encode(
        payload,
        Settings.manage_backend.secret,
        Settings.manage_backend.algorithm,
      )

      Session.create_by_magic(
        magic_link_token: "magic-token",
        email: user.email,
      )

      expect(session_stub.with(
               headers: { "Authorization" => "Bearer #{expected_token}" },
             )).to have_been_made
    end
  end
end
