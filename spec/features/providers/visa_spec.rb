require "rails_helper"

feature "View provider", type: :feature do
  let(:recruitment_cycle_year) { 2022 }
  let(:recruitment_cycle) { build(:recruitment_cycle, year: recruitment_cycle_year) }
  let(:provider) do
    build(
      :provider,
      provider_code: "A0",
      recruitment_cycle_year: recruitment_cycle.year,
      recruitment_cycle: recruitment_cycle,
    )
  end

  before do
    signed_in_user

    provider.recruitment_cycle = recruitment_cycle
    provider.recruitment_cycle_year = recruitment_cycle_year
    stub_api_v2_resource(recruitment_cycle)
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

    context "in recruitment cycle 2021" do
      let(:recruitment_cycle_year) { 2021 }

      it "does not render banner" do
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        expect(page).not_to have_content "You need to provide some information before publishing your courses."
      end
    end

    context "when the provider has not answered the visa sponsorship questions" do
      let(:recruitment_cycle_year) { 2022 }
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

      it "visa sponsorship form renders validation errors if I submit without selecting whether provider sponsors visas" do
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        click_link "Can you sponsor visas?"
        click_button "Save"
        expect(page).to have_content("Select whether your provider can sponsor skilled worker visas")
        expect(page).to have_content("Select whether your provider can sponsor student visas")
      end

      it "visa sponsorship form updates the provider if I submit valid values" do
        stub_api_v2_resource(provider, method: :patch) do |body|
          expect(body["data"]["attributes"]).to eq(
            "can_sponsor_student_visa" => true,
            "can_sponsor_skilled_worker_visa" => false,
          )
        end
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        click_link "Can you sponsor visas?"
        within_fieldset("Can you sponsor Student visas?") do
          choose "Yes"
        end
        within_fieldset("Can you sponsor Skilled Worker visas?") do
          choose "No"
        end
        click_button "Save"
      end

      it "shows a call to action in summary card" do
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        within find("[data-qa='enrichment__can_sponsor_student_visa']") do
          click_link "Select if you can sponsor visas"
        end
        expect(page).to have_content("#{provider.provider_name} Visa sponsorship")
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

      it "about organisation page displays the current visa sponsorship status" do
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        expect(page).to have_content("You can sponsor Student visas")
      end

      it "I can change my answers" do
        stub_api_v2_resource(provider, method: :patch) do |body|
          expect(body["data"]["attributes"]).to eq(
            "can_sponsor_student_visa" => false,
            "can_sponsor_skilled_worker_visa" => true,
          )
        end
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

        within find("[data-qa='enrichment__can_sponsor_student_visa']") do
          click_link "Change"
        end

        within all(".govuk-radios").first do
          choose "No"
        end
        within all(".govuk-radios").last do
          choose "Yes"
        end
        click_button "Save"
      end

      it "does not render banner" do
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        expect(page).not_to have_content "You need to provide some information before publishing your courses."
      end
    end
  end
end
