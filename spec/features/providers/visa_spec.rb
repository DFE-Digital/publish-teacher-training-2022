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
    stub_api_v2_resource(provider, include: "sites")
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
          click_link "Select if visas can be sponsored"
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
        click_link "Select if visas can be sponsored"
        click_button "Save"
        expect(page).to have_content("Select if candidates can get a sponsored Skilled Worker visa")
        expect(page).to have_content("Select if candidates can get a sponsored Student visa")
      end

      it "visa sponsorship form updates the provider if I submit valid values" do
        stub_api_v2_resource(provider, method: :patch) do |body|
          expect(body["data"]["attributes"]).to eq(
            "can_sponsor_student_visa" => true,
            "can_sponsor_skilled_worker_visa" => false,
          )
        end
        visit details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)
        click_link "Select if visas can be sponsored"
        within_fieldset("Can candidates get a sponsored Student visa for your fee-paying courses?") do
          choose "Yes"
        end
        within_fieldset("Can candidates get a sponsored Skilled Worker visa for your salaried courses?") do
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
        expect(page).to have_content("Student visas can be sponsored")
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

        within_fieldset("Can candidates get a sponsored Student visa for your fee-paying courses?") do
          choose "No"
        end
        within_fieldset("Can candidates get a sponsored Skilled Worker visa for your salaried courses?") do
          choose "Yes"
        end
        click_button "Save and publish changes"
      end

      it "course preview page renders the international students section with link to visa sponsorship" do
        course = build(:course, provider: provider)
        stub_api_v2_resource(course, include: "subjects,sites,site_statuses.site,provider.sites,accrediting_provider")
        visit preview_provider_recruitment_cycle_course_path("A0", "2022", course.course_code)
        expect(page).to have_content("International students")
        expect(page).to have_content("We can sponsor Student visas.")
      end
    end

    context "when the provider cannot sponsor visas" do
      let(:provider) do
        build(
          :provider,
          provider_code: "A0",
          recruitment_cycle: recruitment_cycle,
          recruitment_cycle_year: recruitment_cycle.year,
          can_sponsor_student_visa: false,
          can_sponsor_skilled_worker_visa: false,
        )
      end

      it "renders the correct content of on the course preview page" do
        course = build(:course, provider: provider)
        stub_api_v2_resource(course, include: "subjects,sites,site_statuses.site,provider.sites,accrediting_provider")
        visit preview_provider_recruitment_cycle_course_path("A0", "2022", course.course_code)
        expect(page).to have_content("International students")
        expect(page).to have_content("We’re unable to sponsor visas. You’ll need to")
        expect(page).to have_link(
          "get the right visa or status to study in the UK",
          href: "https://www.gov.uk/government/publications/train-to-teach-in-england-non-uk-applicants/train-to-teach-in-england-non-uk-applicants#visas-and-immigration",
        )
      end
    end
  end
end
