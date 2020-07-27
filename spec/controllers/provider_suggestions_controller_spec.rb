require "rails_helper"

RSpec.describe ProviderSuggestionsController do
  let(:user) { build(:user) }

  let(:current_user) do
    {
      user_id: 1,
      uid: SecureRandom.uuid,
      info: {
        email: user.email,
      },
      attributes: user.attributes,
    }.with_indifferent_access
  end

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe "#suggest_any" do
    it "suggests accredited bodies only" do
      stub = stub_request(:get, "http://localhost:3001/api/v2/providers/suggest_any")
        .with(query: { query: "foo" })
        .to_return(
          headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
          body: File.read(Rails.root.join("spec/fixtures/api_responses/provider-suggestions.json")),
        )

      get :suggest_any, params: { query: "foo" }

      expect(stub).to have_been_requested
    end
  end

  describe "#suggest_any_accredited_body" do
    it "suggests accredited bodies only" do
      stub = stub_request(:get, "http://localhost:3001/api/v2/providers/suggest_any")
        .with(query: { query: "foo", filter: { only_accredited_body: "true" } })
        .to_return(
          headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
          body: File.read(Rails.root.join("spec/fixtures/api_responses/provider-suggestions.json")),
        )

      get :suggest_any_accredited_body, params: { query: "foo" }

      expect(stub).to have_been_requested
    end
  end
end
