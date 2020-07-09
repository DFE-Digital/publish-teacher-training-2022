require "rails_helper"

RSpec.describe UsersController do
  let(:user) { create(:user) }

  let(:current_user) do
    {
      "user_id" => user.id,
      "uid" => SecureRandom.uuid,
    }
  end

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(controller).to receive(:authenticate)
    session["auth_user"] ||= {}
    session["auth_user"]["attributes"] ||= {}
  end

  describe "#accept_terms" do
    it "updates session with timestamp" do
      stub_api_v2_request("/users/#{user.id}/accept_terms", user.to_jsonapi, :patch, 200)

      put :accept_terms, params: { user: { terms_accepted: "1" } }
      expect(session["auth_user"]["attributes"]["accept_terms_date_utc"]).to eql(user.as_json["attributes"]["accept_terms_date_utc"])
    end

    it "returns an error when terms haven't been accepted" do
      put :accept_terms, params: { user: { terms_accepted: "0" } }
      expect(response).to render_template("pages/accept_terms")
    end
  end
end
