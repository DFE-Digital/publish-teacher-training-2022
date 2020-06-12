require "rails_helper"

RSpec.xdescribe "Recruitment cycles" do
  let(:provider) { build(:provider) }
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:next_recruitment_cycle) { build(:recruitment_cycle, :next_cycle) }

  before do
    allow(Settings).to receive(:current_cycle_open).and_return(true)
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{next_recruitment_cycle.year}",
      next_recruitment_cycle.to_jsonapi,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}",
      provider.to_jsonapi,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{next_recruitment_cycle.year}/providers/#{provider.provider_code}",
      provider.to_jsonapi,
    )
    get(auth_dfe_callback_path)
  end

  describe "GET show" do
    it "redirects to the course index page" do
      allow(Settings).to receive(:rollover).and_return(false)

      get("/organisations/#{provider.provider_code}/#{current_recruitment_cycle.year}")
      expect(response).to redirect_to(provider_path(provider.provider_code))

      get("/organisations/#{provider.provider_code}/#{next_recruitment_cycle.year}")
      expect(response).to redirect_to(provider_path(provider.provider_code))
    end

    context "rollover" do
      it "renders the recruitment cycle page" do
        allow(Settings).to receive(:rollover).and_return(true)

        get("/organisations/#{provider.provider_code}/#{current_recruitment_cycle.year}")
        expect(response.body).to include("Current cycle")
      end
    end
  end

  describe "when visiting a cycle year that doesn’t exist" do
    scenario "it 404s" do
      get("/organisations/#{provider.provider_code}/1999")
      expect(response).to have_http_status(:not_found)

      get("/organisations/#{provider.provider_code}/1999/courses")
      expect(response).to have_http_status(:not_found)
    end
  end
end
