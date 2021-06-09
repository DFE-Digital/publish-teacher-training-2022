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

    context "when the provider has not answered the visa sponsorship questions" do
      let(:provider) do
        build(
          :provider,
          provider_code: "A0",
          can_sponsor_student_visa: nil,
          can_sponsor_skilled_worker_visa: nil,
        )
      end

      it "renders banner if provider has not answered the visa sponsorship questions" do
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        expect(page).to have_content "You need to provide some information before publishing your courses."
      end

      it "renders validation errors if I submit without selecting whether provider sponsors visas" do
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        click_link "Can you sponsor visas?"
        click_button "Save"
        expect(page).to have_content('Select whether your provider can sponsor skilled worker visas')
        expect(page).to have_content('Select whether your provider can sponsor student visas')
      end
    end

    context "when the provider has answered both visa sponsorship questions" do
      let(:provider) do
        build(
          :provider,
          provider_code: "A0",
          can_sponsor_student_visa: true,
          can_sponsor_skilled_worker_visa: false,
        )
      end

      it "does not render banner" do
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        expect(page).not_to have_content "You need to provide some information before publishing your courses."
      end
    end
  end
end
