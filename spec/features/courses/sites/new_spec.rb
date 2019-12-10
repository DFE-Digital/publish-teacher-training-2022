require "rails_helper"

feature "New course sites", :focus do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:back_new_locations_page) { PageObjects::Page::Organisations::Courses::BackNewLocationsPage.new }
  let(:new_locations_page) { PageObjects::Page::Organisations::Courses::NewLocationsPage.new }
  let(:new_entry_requirements_page) { PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new }
  let(:new_accredited_body_page) { PageObjects::Page::Organisations::Courses::NewAccreditedBodyPage.new }
  let(:site1) { build(:site, location_name: "Site one") }
  let(:site2) { build(:site, location_name: "Site two") }
  let(:site3) { build(:site, location_name: "Another site") }
  let(:sites) { [site1, site2, site3] }
  let(:provider) do
    build(
      :provider,
      sites: sites,
      accredited_body?: true,
      recruitment_cycle: current_recruitment_cycle,
    )
  end
  let(:course) { build(:course, provider: provider) }
  let(:build_course_with_sites_request) { stub_api_v2_build_course(sites_ids: [site2.id]) }
  let(:build_course_with_two_sites_request) { stub_api_v2_build_course(sites_ids: [site1.id, site2.id]) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "?include=sites",
      provider.to_jsonapi(include: [:sites]),
    )
    stub_api_v2_build_course
    build_course_with_sites_request
    build_course_with_two_sites_request
    new_locations_page.load(provider_code: provider.provider_code, recruitment_cycle_year: current_recruitment_cycle.year, course: {})
  end

  context "with multiple sites" do
    scenario "It loads the page" do
      expect(new_locations_page).to be_displayed
    end

    context "Page title" do
      scenario "It displays the correct title" do
        expect(page.title).to start_with("Pick the locations for this course")
        expect(new_locations_page.title.text).to eq("Pick the locations for this course")
      end
    end

    scenario "It displays the providers sites" do
      displayed_site_names = new_locations_page.site_names.collect(&:text)
      expect(displayed_site_names).to eq(["Another site", "Site one", "Site two"])
    end

    scenario "It builds a new course with the selected site" do
      new_locations_page.check(site2.location_name)
      new_locations_page.continue.click

      expect(build_course_with_sites_request).to have_been_made.at_least_once
    end

    scenario "It builds a new course with two selected sites" do
      new_locations_page.check(site1.location_name)
      new_locations_page.check(site2.location_name)
      new_locations_page.continue.click

      expect(build_course_with_two_sites_request).to have_been_made.at_least_once
    end

    scenario "It transitions to the entry requirements page" do
      new_locations_page.check(site2.location_name)
      new_locations_page.continue.click

      expect(new_entry_requirements_page).to be_displayed
    end

    context "with site ids already selected" do
      let(:course) { build(:course, provider: provider, sites: [site3]) }

      scenario "It pre-checks the site" do
        expect(new_locations_page).to have_checked_field(site3.location_name)
      end
    end

    scenario "does not go back to the previous step" do
      back_new_locations_page.load(
        provider_code: provider.provider_code,
        recruitment_cycle_year: current_recruitment_cycle.year,
        course: {}
      )
      expect(new_locations_page).to be_displayed
    end
  end

  context "with only one site" do
    let(:full_or_part_time) { PageObjects::Page::Organisations::Courses::NewStudyModePage.new }
    let(:sites) { [site2] }

    it "sends you to the previous step" do
      back_new_locations_page.load(
        provider_code: provider.provider_code,
        recruitment_cycle_year: current_recruitment_cycle.year,
        course: {}
      )
      expect(full_or_part_time).to be_displayed
    end
  end
end
