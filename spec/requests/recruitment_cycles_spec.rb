require "rails_helper"

describe "Recruitment cycles" do
  let(:provider) { build(:provider) }
  let(:previous_recruitment_cycle) { build(:recruitment_cycle, :previous_cycle) }
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{previous_recruitment_cycle.year}",
      previous_recruitment_cycle.to_jsonapi,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}",
      provider.to_jsonapi,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{previous_recruitment_cycle.year}/providers/#{provider.provider_code}",
      provider.to_jsonapi,
    )
    get(auth_dfe_callback_path)
  end

  describe "GET show" do
    it "redirects to the provider#show page" do
      get("/organisations/#{provider.provider_code}/#{current_recruitment_cycle.year}")
      expect(response).to redirect_to(provider_path(provider.provider_code))
    end

    context "Previous cycle" do
      it "renders the recruitment cycle page" do
        get("/organisations/#{provider.provider_code}/#{previous_recruitment_cycle.year}")
        expect(response.body).to include("Previous cycle (2019 – 2020)")
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
