require "rails_helper"

describe "Providers", type: :request do
  before do
    stub_omniauth
    get(auth_dfe_callback_path)
  end

  describe "GET index" do
    context "with 1 provider" do
      it "redirects to providers show" do
        current_recruitment_cycle = build(:recruitment_cycle)
        provider = build(:provider)
        stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
        stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers", provider.to_jsonapi)
        get(providers_path)
        expect(response).to redirect_to provider_path(provider.provider_code)
      end
    end

    context "with 2 or more providers" do
      it "renders providers index" do
        current_recruitment_cycle = build(:recruitment_cycle)
        provider1 = build(:provider, include_counts: [:courses])
        provider2 = build(:provider, include_counts: [:courses])
        providers = [provider1, provider2]
        stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
        stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers", resource_list_to_jsonapi(providers))
        get(providers_path)
        expect(response.body).to include("Organisations")
        expect(response.body).to include(provider1.provider_name)
      end
    end

    context "user has no providers" do
      it "shows no-providers page" do
        current_recruitment_cycle = build(:recruitment_cycle)
        stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
        stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers", jsonapi(:providers_response, data: []))
        get(providers_path)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("We don’t know which organisation you’re part of")
      end
    end
  end

  describe "GET show" do
    it "render providers show" do
      provider = build(:provider)
      current_recruitment_cycle = build(:recruitment_cycle)
      stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
      stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}", provider.to_jsonapi)
      get(provider_path(provider.provider_code))
      expect(response.body).to include(provider.provider_name)
    end

    context "provider does not exist" do
      it "renders not found" do
        current_recruitment_cycle = build(:recruitment_cycle)
        stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
        stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers/foo", {}, :get, 404)
        get(provider_path("foo"))
        expect(response.body).to include("Page not found")
      end
    end
  end
end
