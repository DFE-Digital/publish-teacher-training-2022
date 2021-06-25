require "rails_helper"

feature "Edit locations", type: :feature do
  let(:site) { jsonapi(:site, location_name: "Main site 1") }
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }

  let(:provider) do
    build(:provider, sites: [site])
  end

  let(:provider_code) { provider.provider_code }
  let(:locations_page) { PageObjects::Page::LocationsPage.new }
  let(:location_page) { PageObjects::Page::LocationPage.new }

  describe "when visiting a site that doesn’t exist" do
    before do
      signed_in_user
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}",
        current_recruitment_cycle.to_jsonapi,
      )
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers/#{provider_code}" \
        "?include=sites",
        provider.to_jsonapi(include: :sites),
      )
    end

    scenario "it 404s" do
      visit edit_provider_recruitment_cycle_site_path(provider_code, Settings.current_cycle, "not_a_site")
      expect(location_page).not_to be_displayed
      expect(page.status_code).to eq(404)
      expect(page.body).to have_content("Page not found")
    end
  end

  describe "without errors" do
    before do
      signed_in_user
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}",
        current_recruitment_cycle.to_jsonapi,
      )
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers/#{provider_code}" \
        "?include=sites",
        provider.to_jsonapi(include: :sites),
      )
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers/#{provider_code}" \
        "/sites/#{site.id}",
        site,
        :patch,
        200,
      )
    end

    scenario "it shows a location" do
      visit edit_provider_recruitment_cycle_site_path(provider_code, site.recruitment_cycle_year, site.id)

      expect(location_page).to be_displayed(provider_code: provider_code, site_id: site.id)
      expect(location_page.title).to have_content("Main site 1")

      location_page.publish_changes.click

      expect(locations_page).to be_displayed
      expect(locations_page.success_summary).to have_content("Your changes have been published")
    end
  end

  describe "with validations errors" do
    before do
      signed_in_user
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}",
        current_recruitment_cycle.to_jsonapi,
      )
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers/#{provider_code}" \
        "?include=sites",
        provider.to_jsonapi(include: :sites),
      )
      stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider_code}/sites/#{site.id}", build(:error), :patch, 422)
    end

    scenario "displays validation errors" do
      visit(edit_provider_recruitment_cycle_site_path(
              provider_code,
              site.recruitment_cycle_year,
              site.id,
            ))

      expect(location_page).to be_displayed(provider_code: provider_code, site_id: site.id)

      location_page.publish_changes.click

      expect(location_page).to be_displayed(provider_code: provider_code, site_id: site.id)
      expect(location_page.error_summary).to have_content("Name is missing")
      expect(location_page.error_summary).to have_content("Postcode is missing")
    end

    scenario "displays the old location name when the change fails" do
      visit edit_provider_recruitment_cycle_site_path(provider_code, site.recruitment_cycle_year, site.id)

      expect(location_page.title).to have_content("Main site 1")

      location_page.name_field.set "Main site 2"
      location_page.publish_changes.click

      expect(location_page.title).to have_content("Main site 1")
    end
  end
end
