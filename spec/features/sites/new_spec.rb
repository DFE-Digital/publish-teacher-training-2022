require "rails_helper"

feature "Locations", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}?include=sites",
      provider.to_jsonapi(include: :sites),
    )
  end

  context "with provider with few sites" do
    scenario "locations page should have Add a location button" do
      visit provider_recruitment_cycle_sites_path(provider.provider_code, current_recruitment_cycle.year)

      expect(page).to have_content("Add a location")
    end
  end

  context "with provider with the maximum number of sites" do
    let(:provider) { build(:provider, can_add_more_sites?: false) }

    scenario "locations page should not have Add a location button" do
      visit provider_recruitment_cycle_sites_path(provider.provider_code, current_recruitment_cycle.year)

      expect(page).to have_content("you’ve reached the maximum number of locations available")
    end
  end

  context "without validation errors" do
    before do
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/sites",
        nil,
        :post,
      )
    end

    scenario "Adding a location" do
      visit provider_recruitment_cycle_sites_path(provider.provider_code, current_recruitment_cycle.year)

      click_on "Add a location"

      fill_in "Name", with: "New site"
      fill_in "Building and street", with: "New building and street"
      fill_in "Town or city", with: "New town"
      fill_in "County", with: "New county"
      fill_in "Postcode", with: "SW1A 1AA"


      click_on "Save"

      expect(page).to have_content("Your location has been created")
    end
  end

  context "with validations errors" do
    before do
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/sites",
        build(:error),
        :post,
        422,
      )
    end

    scenario "Adding a location with validation errors" do
      visit new_provider_recruitment_cycle_site_path(provider.provider_code, current_recruitment_cycle.year)

      click_on "Save"

      expect(page).to have_content("Name is missing")
    end
  end
end
