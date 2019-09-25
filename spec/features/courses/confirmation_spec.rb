require "rails_helper"

feature "Course confirmation", type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:course_confirmation_page) do
    PageObjects::Page::Organisations::CourseConfirmation.new
  end
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider)
    stub_api_v2_resource_collection([new_course], include: "sites,provider.sites,accrediting_provider")
    stub_api_v2_new_resource(new_course)
  end

  scenario "viewing the course details page" do
    visit confirmation_provider_recruitment_cycle_courses_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
          )

    expect(course_confirmation_page.title).to have_content(
      "Check your answers before confirming",
    )
  end
end
