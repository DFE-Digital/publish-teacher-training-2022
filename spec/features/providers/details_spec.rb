require "rails_helper"

feature "View provider", type: :feature do
  include SiteHelper

  let(:org_detail_page) { PageObjects::Page::Organisations::OrganisationDetails.new }
  let(:org_contact_page) { PageObjects::Page::Organisations::OrganisationContact.new }

  before do
    allow(Settings.features.rollover).to receive(:has_current_cycle_started?).and_return(true)
    signed_in_user

    stub_api_v2_resource(provider.recruitment_cycle)
    stub_api_v2_resource(provider)

    visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
  end

  context "with empty provider details" do
    let(:provider) do
      build :provider,
            provider_code: "A0",
            content_status: "empty",
            last_published_at: nil
    end

    it "renders correctly" do
      test_details_page
    end
  end

  context "with draft provider details" do
    let(:provider) do
      build :provider,
            provider_code: "A0",
            content_status: "draft"
    end

    it "renders correctly" do
      test_details_page
    end
  end

  context "with published provider details" do
    let(:provider) do
      build :provider,
            provider_code: "A0",
            content_status: "published"
    end

    it "renders correctly" do
      test_details_page
    end
  end

  def test_details_page
    expect_breadcrumbs_to_be_correct

    expect(current_path).to eq details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

    expect(org_detail_page).to have_link(
      "Change contact address",
      href: new_publish_link_for("/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/contact#address"),
    )

    expect(org_detail_page.email).to have_content(provider.email)
    expect(org_detail_page.website).to have_content(provider.website)
    expect(org_detail_page.telephone).to have_content(provider.telephone)

    expect(org_detail_page).to have_link(
      "details about training with your organisation",
      href: new_publish_link_for("/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/about#train-with-us"),
    )
    expect(org_detail_page.train_with_us).to have_content(provider.train_with_us)
    expect(org_detail_page.train_with_disability).to have_content(provider.train_with_disability)
    expect(org_detail_page).to have_status_panel
  end

  def expect_breadcrumbs_to_be_correct
    breadcrumbs = org_detail_page.breadcrumbs

    expect(breadcrumbs[0].text).to eq(provider.provider_name)
    expect(breadcrumbs[0]["href"]).to eq("/organisations/#{provider.provider_code}")

    if FeatureService.enabled?("rollover.can_edit_current_and_next_cycles")
      expect(breadcrumbs[1].text).to eq(provider.recruitment_cycle.title)
      expect(breadcrumbs[1]["href"]).to eq("/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}")
    end
  end

  context "when a provider doesnt have a UKPRN" do
    let(:provider) { build(:provider, ukprn: nil) }

    it "redirects the provider to their contact's page with a validation message" do
      expect(current_path).to eq contact_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
      expect(org_contact_page.error_flash).to have_content("Please enter a UKPRN before continuing")
    end
  end
end
