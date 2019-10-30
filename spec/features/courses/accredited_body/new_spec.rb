require "rails_helper"

feature "Edit accredited body", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider) }
  let(:new_accredited_body_page) { PageObjects::Page::Organisations::Courses::NewAccreditedBodyPage.new }
  let(:new_accredited_body_search_page) { PageObjects::Page::Organisations::Courses::NewAccreditedBodySearchPage.new }
  let(:accrediting_provider_1) { build(:provider) }
  let(:accrediting_provider_2) { build(:provider) }
  let(:accredited_bodies) {
    [
      { "provider_name": accrediting_provider_1.provider_name, "provider_code" => accrediting_provider_1.provider_code },
      { "provider_name": accrediting_provider_2.provider_name, "provider_code" => accrediting_provider_2.provider_code },
    ]
  }

  before do
    stub_omniauth(provider: provider)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_build_course
    stub_api_v2_build_course(level: "primary")

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
      expect(suggested_providers[0]). to eq("#{accrediting_provider_1.provider_name} (#{accrediting_provider_1.provider_code})")
      expect(suggested_providers[1]). to eq("#{accrediting_provider_2.provider_name} (#{accrediting_provider_2.provider_code})")
    end

    context "when selecting an accredited body" do
      let(:next_step_page) { PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new }
      let(:selected_fields) { { level: "primary", accrediting_provider_code: accrediting_provider_1.provider_code } }
      let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

      before do
        build_course_with_selected_value_request
        choose accrediting_provider_1.provider_name
        new_accredited_body_page.continue.click
      end

      include_examples "a course creation page"
    end

    context "Searching for a new accredited body" do
      context "with some results" do
        before do
          stub_api_v2_build_course(level: "primary", accrediting_provider_code: "other")
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
          let(:selected_fields) { { level: "primary", accrediting_provider_code: "A01" } }
          let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

          before do
            build_course_with_selected_value_request
            choose "ACME 1"
            new_accredited_body_search_page.continue.click
          end

          include_examples "a course creation page"
        end
      end
    end
  end

private

  def searching_returns_some_results
    stub_api_v2_request(
      "/providers/suggest?query=ACME",
      resource_list_to_jsonapi([
        build(:provider_suggestion, provider_name: "ACME 1", provider_code: "A01"),
        build(:provider_suggestion, provider_name: "ACME 2"),
        build(:provider_suggestion, provider_name: "ACME 3"),
        build(:provider_suggestion, provider_name: "ACME 4"),
      ]),
    )
  end

  def searching_returns_no_results
    stub_api_v2_request(
      "/providers/suggest?query=ACME",
      resource_list_to_jsonapi([]),
    )
  end
end
