require 'rails_helper'

feature 'View provider', type: :feature do
  let(:org_detail_page) { PageObjects::Page::Organisations::OrganisationDetails.new }
  let(:provider) do
    build :provider,
          provider_code: 'A0',
          content_status: 'published'
  end

  scenario 'viewing organisation details page' do
    allow(Settings).to receive(:rollover).and_return(false)
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}",
      provider.to_jsonapi
    )

    visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

    expect(current_path).to eq details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

    expect(org_detail_page).to have_link(
      'Contact details',
      href: "#{Settings.manage_ui.base_url}/organisation/#{provider.provider_code}/contact"
    )
    expect(org_detail_page.caption).to have_content(provider.provider_name)
    expect(org_detail_page.email).to have_content(provider.email)
    expect(org_detail_page.website).to have_content(provider.website)
    expect(org_detail_page.telephone).to have_content(provider.telephone)

    expect(org_detail_page).to have_link(
      'About your organisation',
      href: "#{Settings.manage_ui.base_url}/organisation/#{provider.provider_code}/about"
    )
    expect(org_detail_page.train_with_us).to have_content(provider.train_with_us)
    expect(org_detail_page.train_with_disability).to have_content(provider.train_with_disability)
  end
end
