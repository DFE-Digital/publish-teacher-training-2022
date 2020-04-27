require "rails_helper"

describe "Notifications" do
  describe "GET notifications" do
    before do
      stub_omniauth
      get(auth_dfe_callback_path)
    end

    it "returns 200" do
      get "/notifications"
      expect(response).to have_http_status(200)
      expect(response.header["Content-Type"]).to include "text/html"
      expect(response.body).to include("Manage notifications")
    end
  end
end
