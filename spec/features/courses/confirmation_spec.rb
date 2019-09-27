require "rails_helper"

feature "Course confirmation", type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:course_confirmation_page) do
    PageObjects::Page::Organisations::CourseConfirmation.new
  end
  let(:course) { build(:course) }
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider)
    stub_api_v2_resource_collection([new_course], include: "sites,provider.sites,accrediting_provider")
    stub_api_v2_new_resource(new_course)
    stub_api_v2_build_course
  end

  scenario "viewing the course details page" do
    visit confirmation_provider_recruitment_cycle_courses_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
    )

    expect(course_confirmation_page.title).to have_content(
      "Check your answers before confirming",
    )

    expect(course_confirmation_page.details.level.text).to eq(course.level.capitalize)
    expect(course_confirmation_page.details.is_send.text).to eq("No")
    expect(course_confirmation_page.details.subjects.text).to include("English")
    expect(course_confirmation_page.details.subjects.text).to include("English with Primary")
    expect(course_confirmation_page.details.age_range.text).to eq("11 to 16")
    expect(course_confirmation_page.details.study_mode.text).to eq("Full time")
    expect(course_confirmation_page.details.locations.text).to eq("None")
    expect(course_confirmation_page.details.application_open_from.text).to eq("1 January 2019")
    expect(course_confirmation_page.details.start_date.text).to eq("January 2019")
    expect(course_confirmation_page.details.name.text).to eq("English")
    expect(course_confirmation_page.details.description.text).to eq("PGCE with QTS full time")
    expect(course_confirmation_page.details.entry_requirements.text).to include("Maths GCSE: Taking")
    expect(course_confirmation_page.details.entry_requirements.text).to include("English GCSE: Must have")
  end
end
