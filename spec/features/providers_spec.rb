require "rails_helper"

feature "View providers", type: :feature do
  let(:organisation_page) { PageObjects::Page::Organisations::OrganisationPage.new }
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider_1) { build :provider, provider_code: "A0", include_counts: [:courses] }
  let(:provider_2) { build :provider, provider_code: "A1", include_counts: [:courses] }
  let(:provider_response) { provider_1.to_jsonapi(include: %i[courses accrediting_provider]) }
  let(:providers_response) do
    resource_list_to_jsonapi([provider_1, provider_2])
  end

  scenario "Navigate to /organisations" do
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers",
      providers_response,
    )

    visit providers_path
    expect(find("h1")).to have_content("Organisations")
    expect(first(".govuk-list li")).to have_content(provider_1.provider_name.to_s)
  end


  scenario "Navigate to /organisations/A0" do
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider_1.provider_code}",
      provider_response,
    )

    visit provider_path(provider_1.provider_code)
    expect(find("h1")).to have_content(provider_1.provider_name.to_s)
    expect(organisation_page).not_to have_selector(".govuk-breadcrumbs")

    expect(organisation_page).to have_current_cycle

    expect(organisation_page).to have_link("Locations", href: "/organisations/A0/#{current_recruitment_cycle.year}/locations")
    expect(organisation_page).to have_link("Courses", href: "/organisations/A0/#{current_recruitment_cycle.year}/courses")
    expect(organisation_page).to have_link("UCAS contacts", href: "/organisations/A0/ucas-contacts")
  end
end
