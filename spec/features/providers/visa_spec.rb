require "rails_helper"

feature "View and edit provider visa sponsorship", type: :feature do
  let(:recruitment_cycle_year) { 2022 }
  let(:recruitment_cycle) { build(:recruitment_cycle, year: recruitment_cycle_year) }
  let(:provider) do
    build(
      :provider,
      recruitment_cycle: recruitment_cycle,
      recruitment_cycle_year: recruitment_cycle.year,
    )
  end

  before do
    signed_in_user

    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource(provider)
  end

  context "in recruitment cycle 2021" do
    let(:recruitment_cycle_year) { 2021 }

    it "does not render visa sponsorship prompt and link" do
      visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
      expect(page).not_to have_content "Select if you can sponsor visas"
    end

    it "course preview page does not render international students section" do
      course = build(:course, provider: provider)
      stub_api_v2_resource(course, include: "subjects,sites,site_statuses.site,provider.sites,accrediting_provider")
      visit preview_provider_recruitment_cycle_course_path(
        provider.provider_code,
        recruitment_cycle_year,
        course.course_code,
      )
      expect(page).not_to have_content("International students")
    end
  end

  context "in recruitment cycle 2022" do
    context "when the provider has not answered the visa sponsorship questions" do
      let(:recruitment_cycle_year) { 2022 }
      let(:provider) do
        build(
          :provider,
          provider_code: "A0",
          recruitment_cycle: recruitment_cycle,
          recruitment_cycle_year: recruitment_cycle.year,
          can_sponsor_student_visa: nil,
          can_sponsor_skilled_worker_visa: nil,
        )
      end

      it "shows a call to action in summary card" do
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        within find("[data-qa='enrichment__can_sponsor_student_visa']") do
          click_link "Select if you can sponsor visas"
        end
        expect(page).to have_content("#{provider.provider_name} Visa sponsorship")
      end

      it "course preview page renders the international students section with link to visa sponsorship" do
        course = build(:course, provider: provider)
        stub_api_v2_resource(course, include: "subjects,sites,site_statuses.site,provider.sites,accrediting_provider")
        visit preview_provider_recruitment_cycle_course_path("A0", "2022", course.course_code)
        expect(page).to have_content("International students")
        expect(page).to have_content("Please add details about visa sponsorship")
      end

      it "visa sponsorship form renders validation errors if I submit without selecting whether provider sponsors visas" do
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        click_link "Select if you can sponsor visas"
        click_button "Save"
        expect(page).to have_content("Select if you can sponsor Skilled Worker visas")
        expect(page).to have_content("Select if you can sponsor Student visas")
      end

      it "visa sponsorship form updates the provider if I submit valid values" do
        stub_api_v2_resource(provider, method: :patch) do |body|
          expect(body["data"]["attributes"]).to eq(
            "can_sponsor_student_visa" => true,
            "can_sponsor_skilled_worker_visa" => false,
          )
        end
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        click_link "Select if you can sponsor visas"
        within_fieldset("Can you sponsor Student visas?") do
          choose "Yes"
        end
        within_fieldset("Can you sponsor Skilled Worker visas?") do
          choose "No"
        end
        click_button "Save and publish changes"
      end
    end

    context "when the provider has answered both visa sponsorship questions" do
      let(:provider) do
        build(
          :provider,
          provider_code: "A0",
          recruitment_cycle: recruitment_cycle,
          recruitment_cycle_year: recruitment_cycle.year,
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

        within_fieldset("Can you sponsor Student visas?") do
          choose "No"
        end
        within_fieldset("Can you sponsor Skilled Worker visas?") do
          choose "Yes"
        end
        click_button "Save and publish changes"
      end

      it "course preview page renders the international students section with link to visa sponsorship" do
        course = build(:course, provider: provider)
        stub_api_v2_resource(course, include: "subjects,sites,site_statuses.site,provider.sites,accrediting_provider")
        visit preview_provider_recruitment_cycle_course_path("A0", "2022", course.course_code)
        expect(page).to have_content("International students")
        expect(page).to have_content("We can sponsor Student visas, but this is not guaranteed.")
      end
    end
  end
end
