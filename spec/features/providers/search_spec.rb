require "rails_helper"

feature "Search providers", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:rollover) { false }
  let(:provider1) { build(:provider, provider_code: "A0", include_counts: [:courses]) }
  let(:provider2) { build(:provider, provider_code: "A1", include_counts: [:courses]) }
  let(:root_page) { PageObjects::Page::RootPage.new }
  let(:organisation_page) { PageObjects::Page::Organisations::OrganisationPage.new }
  let(:user) { build :user, :admin }
  let(:access_request) { build :access_request }

  before do
    signed_in_user(user: user)
    stub_api_v2_resource_collection([access_request])

    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi,
    )

    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers?page[page]=1",
      resource_list_to_jsonapi([provider1, provider2], meta: { count: 2 }),
    )

    allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(rollover)

    root_page.load
  end

  context "Searching for a known provider" do
    it "redirects to the provider page" do
      provider_response = provider1.to_jsonapi(include: %i[courses accrediting_provider])

      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers/#{provider1.provider_code}",
        provider_response,
      )

      root_page.provider_search.fill_in(with: provider1.provider_code)
      root_page.find_providers.click

      expect(current_path).to eq("/organisations/#{provider1.provider_code}")
    end
  end

  context "Blank provider search" do
    it "displays an error" do
      root_page.find_providers.click

      expect(root_page.error_summary).to have_content(
        "There is a problem",
      )

      expect(root_page.provider_error).to have_content(
        "Please enter the name or provider code",
      )
      expect(current_path).to eq("/")
    end
  end

  context "Searching for an unknown provider" do
    it "redirects to 'not found'" do
      provider_code = "234"

      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers/#{provider_code}",
        {},
        :get,
        404,
      )

      root_page.provider_search.fill_in(with: "Unknown Provider (#{provider_code})")
      root_page.find_providers.click

      expect(current_path).to eq("/organisations/#{provider_code}")
      expect(organisation_page).to have_not_found
    end
  end
end
