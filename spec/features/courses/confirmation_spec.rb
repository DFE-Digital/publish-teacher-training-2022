require "rails_helper"

feature "Course confirmation", type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:course_confirmation_page) do
    PageObjects::Page::Organisations::CourseConfirmation.new
  end
  let(:course_page) do
    PageObjects::Page::Organisations::Course.new
  end

  let(:course) { build(:course, provider: provider, subjects: [build(:subject, subject_name: "English"), build(:subject, subject_name: "English with Primary")]) }
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider)
    stub_api_v2_resource_collection([new_course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_new_resource(new_course)
    stub_api_v2_build_course

    visit confirmation_provider_recruitment_cycle_courses_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      course: {
        level: course.level,
      },
    )

    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_build_course
  end

  scenario "viewing the course details page" do
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

  context "Saving the course" do
    context "Successfully" do
      scenario "It creates the course on the API" do
        course.course_code = "A123"
        stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
        course_create_request = stub_api_v2_request(
          "/recruitment_cycles/#{course.recruitment_cycle.year}" \
          "/providers/#{provider.provider_code}" \
          "/courses",
          course.to_jsonapi,
          :post, 200
        )

        course_confirmation_page.save.click

        expect(course_create_request).to have_been_made
      end

      scenario "It displays the course page when created" do
        course.course_code = "A123"
        stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
        stub_api_v2_request(
          "/recruitment_cycles/#{course.recruitment_cycle.year}" \
          "/providers/#{provider.provider_code}" \
          "/courses",
          course.to_jsonapi,
          :post, 200
        )

        course_confirmation_page.save.click

        expect(course_page).to be_displayed
      end
    end

    context "With errors" do
      scenario "It renders the confirmation page" do
        stub_api_v2_request(
          "/recruitment_cycles/#{course.recruitment_cycle.year}" \
          "/providers/#{provider.provider_code}" \
          "/courses",
          {
            errors: [
              {
                "source": { "pointer": "/data/attributes/cats" },
                "title":  "You need more cats",
                "detail": "Cats are important",
              },
            ],
          },
          :post, 200
        )

        course_confirmation_page.save.click

        expect_course_confirmation_page_to_display_course_information
        expect(course_confirmation_page).to have_content(
          "Cats are important",
        )
      end
    end
  end

private

  def expect_course_confirmation_page_to_display_course_information
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
