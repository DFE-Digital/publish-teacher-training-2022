require 'rails_helper'

feature 'View provider', type: :feature do
  let(:org_detail_page) { PageObjects::Page::Organisations::OrganisationDetails.new }

  before do
    stub_omniauth
  end

  context "with empty provider details" do
    let(:provider) do
      build :provider,
            provider_code: 'A0',
            content_status: 'empty',
            last_published_at: nil
    end

    it 'renders correctly' do
      test_details_page 'Empty'
    end
  end

  context "with draft provider details" do
    let(:provider) do
      build :provider,
            provider_code: 'A0',
            content_status: 'draft'
    end

    it 'renders correctly' do
      test_details_page 'Draft'
    end
  end

  context "with published provider details" do
    let(:provider) do
      build :provider,
            provider_code: 'A0',
            content_status: 'published'
    end

    it 'renders correctly' do
      test_details_page 'Published'
    end
  end

  def test_details_page(expected_status)
    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}",
      provider.recruitment_cycle.to_jsonapi
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}",
      provider.to_jsonapi
    )

    visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

    expect_breadcrumbs_to_be_correct

    expect(current_path).to eq details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

    expect(org_detail_page).to have_link(
      'Contact details',
      href: "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/contact"
    )
    expect(org_detail_page.caption).to have_content(provider.provider_name)
    expect(org_detail_page.email).to have_content(provider.email)
    expect(org_detail_page.website).to have_content(provider.website)
    expect(org_detail_page.telephone).to have_content(provider.telephone)

    expect(org_detail_page).to have_link(
      'About your organisation',
      href: "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/about"
    )
    expect(org_detail_page.train_with_us).to have_content(provider.train_with_us)
    expect(org_detail_page.train_with_disability).to have_content(provider.train_with_disability)

    expect(org_detail_page).to have_status_panel
    expect(org_detail_page.content_status).to have_content(expected_status)
  end

  def expect_breadcrumbs_to_be_correct
    breadcrumbs = org_detail_page.breadcrumbs

    expect(breadcrumbs[0].text).to eq(provider.provider_name)
    expect(breadcrumbs[0]["href"]).to eq("/organisations/#{provider.provider_code}")

    expect(breadcrumbs[1].text).to eq(provider.recruitment_cycle.title)
    expect(breadcrumbs[1]["href"]).to eq("/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}")
  end
end
