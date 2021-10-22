require "rails_helper"

feature "courses page", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:courses_page) { PageObjects::Page::Organisations::CoursesPage.new }
  let(:new_level_page) { PageObjects::Page::Organisations::Courses::NewLevelPage.new }
  let(:new_locations_page) { PageObjects::Page::NewLocationsPage.new }
  let(:site) { build(:site) }
  let(:course) { build(:course, provider: provider) }
  let(:provider) { build(:provider, sites: [site]) }

  before do
    signed_in_user
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")

    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider, include: "sites")
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course

    courses_page.load_with_provider(provider)
  end

  context "when sites are present" do
    scenario "links to the course creation page" do
      courses_page.course_create.click
      expect(new_level_page).to be_displayed
    end
  end

  context "when sites are present" do
    let(:provider) { build(:provider, sites: []) }

    scenario "links to the course creation page" do
      courses_page.course_create.click
      expect(new_locations_page).to be_displayed
    end
  end
end
