require "rails_helper"

feature "View provider", type: :feature do
  let(:org_detail_page) { PageObjects::Page::Organisations::OrganisationDetails.new }
  let(:provider) do
    build :provider, provider_code: "A0"
  end

  before do
    signed_in_user

    stub_api_v2_resource(provider.recruitment_cycle)
    stub_api_v2_resource(provider)
  end

  context "with feature flag off" do
    before do
      allow(Settings.features.rollover).to receive(:prepare_for_next_cycle).and_return(false)
    end

    it "does not render banner" do
      visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
      expect(page).not_to have_content "You need to provide some information before publishing your courses."
    end
  end

  context "with feature flag on" do
    before do
      allow(Settings.features.rollover).to receive(:prepare_for_next_cycle).and_return(true)
    end

    it "does not render banner" do
      visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
      expect(page).to have_content "You need to provide some information before publishing your courses."
    end
  end
end
