require "rails_helper"

feature "New accredited body" do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider, sites: [build(:site)]) }
  let(:course) { build(:course, provider: provider) }
  let(:new_accredited_body_page) { PageObjects::Page::Organisations::Courses::NewAccreditedBodyPage.new }
  let(:new_accredited_body_search_page) { PageObjects::Page::Organisations::Courses::NewAccreditedBodySearchPage.new }
  let(:accrediting_provider_1) { build(:provider) }
  let(:accrediting_provider_2) { build(:provider) }
  let(:accredited_bodies) do
    [
      { "provider_name": accrediting_provider_1.provider_name, "provider_code" => accrediting_provider_1.provider_code },
      { "provider_name": accrediting_provider_2.provider_name, "provider_code" => accrediting_provider_2.provider_code },
    ]
  end

  before do
    stub_omniauth(provider: provider)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider, include: "sites")
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_build_course
    stub_api_v2_build_course(level: "primary")

    stub_api_v2_request(
      "/recruitment_cycles/2020/providers?page[page]=1",
      resource_list_to_jsonapi([provider], meta: { count: 1 }),
    )

    visit signin_path
    visit new_provider_recruitment_cycle_courses_accredited_body_path(
      provider.provider_code,
      current_recruitment_cycle.year,
      course: { level: "primary" },
    )
  end

  context "A provider with accredited bodies" do
    let(:provider) { build(:provider, accredited_bodies: accredited_bodies) }

    scenario "It displays the accredited bodies" do
      suggested_providers = new_accredited_body_page.suggested_accredited_bodies.map(&:text)
      expect(suggested_providers).to include(
        "#{accrediting_provider_1.provider_name} (#{accrediting_provider_1.provider_code})",
        "#{accrediting_provider_2.provider_name} (#{accrediting_provider_2.provider_code})",
      )
    end

    context "when selecting an accredited body" do
      let(:next_step_page) { PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new }
      let(:selected_fields) { { level: "primary", accredited_body_code: accrediting_provider_1.provider_code } }
      let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

      before do
        build_course_with_selected_value_request
        choose accrediting_provider_1.provider_name
        new_accredited_body_page.continue.click
      end

      include_examples "a course creation page"
    end

    context "It allows the user to go back" do
      context "With a single site" do
        let(:new_study_mode_page) { PageObjects::Page::Organisations::Courses::NewStudyModePage.new }

        it "Returns to the study mode page" do
          new_accredited_body_page.back.click
          expect(new_study_mode_page).to be_displayed
        end
      end

      context "with multiple sites" do
        let(:provider) { build(:provider, sites: [build(:site), build(:site)]) }
        let(:new_locations_page) { PageObjects::Page::Organisations::Courses::NewLocationsPage.new }

        it "Returns to the locations page" do
          new_accredited_body_page.back.click
          expect(new_locations_page).to be_displayed
        end
      end
    end

    context "Searching for a new accredited body" do
      context "with some results" do
        before do
          stub_api_v2_build_course(level: "primary", accredited_body_code: "other")
          searching_returns_some_results
          choose "A new accredited body you’re working with"
          fill_in "Name of accredited body", with: "ACME"
          new_accredited_body_page.continue.click
        end

        scenario "It displays the search new page" do
          expect(new_accredited_body_search_page).to be_displayed
        end

        context "When selecting an accredited body" do
          let(:next_step_page) { PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new }
          let(:selected_fields) { { level: "primary", accredited_body_code: "A01" } }
          let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

          before do
            build_course_with_selected_value_request
            choose "ACME 1"
            new_accredited_body_search_page.continue.click
          end

          include_examples "a course creation page"
        end

        context "When not selecting an accredited body" do
          let(:next_step_page) { PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new }
          let(:selected_fields) { { level: "primary", accredited_body_code: "A01" } }
          let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

          before do
            build_course_with_selected_value_request
            new_accredited_body_search_page.continue.click
          end

          scenario "it raises a validation error" do
            expect(new_accredited_body_search_page).to have_content("Pick an accredited body")
          end
        end

        context "When searching for an accredited body with fewer than two characters" do
          let(:next_step_page) { PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new }
          let(:selected_fields) { { level: "primary", accredited_body_code: "A01" } }
          let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

          before do
            build_course_with_selected_value_request
            choose "other"
            new_accredited_body_search_page.continue.click
          end

          scenario "it raises a validation error" do
            expect(new_accredited_body_search_page).to have_content("Accredited body search too short, enter 2 or more characters")
          end
        end
      end
    end
  end

  context "Page title" do
    scenario "It displays the correct title" do
      expect(page.title).to start_with("Who is the accredited body?")
      expect(new_accredited_body_search_page.title.text).to eq("Who is the accredited body?")
    end
  end

private

  def searching_returns_some_results
    stub_api_v2_request(
      "/providers/suggest_any?query=ACME&filter[only_accredited_body]=true",
      resource_list_to_jsonapi([
        build(:provider_suggestion, provider_name: "ACME 1", provider_code: "A01"),
        build(:provider_suggestion, provider_name: "ACME 2"),
        build(:provider_suggestion, provider_name: "ACME 3"),
        build(:provider_suggestion, provider_name: "ACME 4"),
      ]),
    )
  end
end
