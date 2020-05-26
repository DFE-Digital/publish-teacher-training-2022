require "rails_helper"

feature "courses page", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:courses_page) { PageObjects::Page::Organisations::CoursesPage.new }
  let(:new_level_page) { PageObjects::Page::Organisations::Courses::NewLevelPage.new }
  let(:course) { build(:course, provider: provider) }
  let(:provider) { build(:provider) }

  scenario "links to the course creation page" do
    stub_omniauth
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")

    stub_api_v2_resource(provider)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course

    courses_page.load_with_provider(provider)
    courses_page.course_create.click
    expect(new_level_page).to be_displayed
  end
end
