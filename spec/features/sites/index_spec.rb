require "rails_helper"

feature "View locations", type: :feature, skip: true do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:sites) do
    [
      build(:site, location_name: "Main site 1"),
      build(:site, location_name: "Main site 2"),
      build(:site, location_name: "Main site 3"),
    ]
  end

  let(:provider) do
    build(:provider, sites: sites)
  end
  let(:provider_code) { provider.provider_code }
  let(:site_response) { sites[0].to_jsonapi }
  let(:root_page) { PageObjects::Page::RootPage.new }
  let(:organisation_page) { PageObjects::Page::Organisations::OrganisationPage.new }
  let(:locations_page) { PageObjects::Page::LocationsPage.new }
  let(:location_page) { PageObjects::Page::LocationPage.new }
  let(:user) { build(:user) }

  before do
    allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(false)
    signed_in_user(user: user, provider: provider)

    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      resource_list_to_jsonapi(current_recruitment_cycle),
    )

    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers?page[page]=1",
      resource_list_to_jsonapi([provider], include: :sites, meta: { count: 1 }),
    )

    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider_code}",
      provider.to_jsonapi,
    )

    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider_code}?include=sites",
      provider.to_jsonapi(include: :sites),
    )

    stub_request(:get, "#{Settings.teacher_training_api.base_url}/api/v2/recruitment_cycles/#{Settings.current_cycle.succ}/providers/#{provider_code}")

    stub_interrupt_acknowledgements

    root_page.load

    expect(organisation_page).to be_displayed(provider_code: provider_code)

    organisation_page.locations.click
  end

  scenario "it shows a list of locations" do
    expect(locations_page).to be_displayed(provider_code: provider_code)
    expect(locations_page.title).to have_content("Locations")
    expect(locations_page.locations.size).to eq(3)
    expect(locations_page.locations.first).to have_hyperlink
    expect(locations_page.locations.first.cell.text).to eq("Main site 1")
    expect(locations_page).to have_add_a_location_link
  end

  scenario "it shows one location" do
    stub_api_v2_request("/providers/#{provider_code}/sites/#{sites.first.id}", site_response)

    expect(locations_page.locations.first).to have_hyperlink
    locations_page.locations.first.hyperlink.click

    expect(location_page).to be_displayed(provider_code: provider_code, site_id: sites[0].id)
    expect(location_page.title).to have_content("Main site 1")
  end

  scenario "prompts users to add new locations" do
    expect(locations_page).to have_add_a_location_link
  end

  context "rollover" do
    it "it shows a list of locations" do
      allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(true)
      signed_in_user(user: user, provider: provider)
      root_page.load
      expect(organisation_page).to be_displayed(provider_code: provider_code)
      organisation_page.current_cycle.click
      organisation_page.locations.click

      expect(locations_page).to be_displayed(provider_code: provider_code)
      expect(locations_page.title).to have_content("Locations")
      expect(locations_page.locations.size).to eq(3)
    end
  end
end
