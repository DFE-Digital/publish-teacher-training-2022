require "rails_helper"

feature "Deleting a location", type: :feature do
  let(:site) { jsonapi(:site, location_name: "Main site 1") }
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }

  let(:provider) do
    build(:provider, sites: [site])
  end

  let(:provider_code) { provider.provider_code }
  let(:locations_page) { PageObjects::Page::LocationsPage.new }
  let(:location_delete_page) { PageObjects::Page::LocationDeletePage.new }

  before do
    signed_in_user
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
      {},
      :delete,
      204,
    )
  end
  scenario "it deletes a location" do
    visit delete_provider_recruitment_cycle_site_path(provider_code, site.recruitment_cycle_year, site.id)

    expect(location_delete_page).to be_displayed(provider_code: provider_code, site_id: site.id)
    expect(location_delete_page.title).to have_content("Main site 1")

    location_delete_page.confirm_field.fill_in(with: site.location_name)
    location_delete_page.submit_button.click

    expect(locations_page).to be_displayed
    expect(locations_page.success_summary).to have_content("Main site 1 has been deleted")
  end

  scenario "with incorrect confirmation" do
    visit delete_provider_recruitment_cycle_site_path(provider_code, site.recruitment_cycle_year, site.id)

    location_delete_page.confirm_field.fill_in(with: "Obviously wrong site name")
    location_delete_page.submit_button.click

    expect(location_delete_page).to be_displayed
    expect(location_delete_page.error_summary).to have_content("Enter the site name (Main site 1) to delete this site")
  end
end
