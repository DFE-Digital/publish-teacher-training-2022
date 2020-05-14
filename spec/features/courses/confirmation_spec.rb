require "rails_helper"

feature "Course confirmation", type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle, application_start_date: "2019-08-08") }
  let(:course_confirmation_page) do
    PageObjects::Page::Organisations::CourseConfirmation.new
  end
  let(:course_page) do
    PageObjects::Page::Organisations::Course.new
  end
  let(:site1) { build(:site, location_name: "Site one") }
  let(:site2) { build(:site, location_name: "Site two") }
  let(:study_mode) { "full_time" }
  let(:level) { :secondary }
  let(:course) do
    build(
      :course,
      provider: provider,
      sites: [site1, site2],
      study_mode: study_mode,
      level: level,
      subjects: [
        build(:subject, :english),
        build(:subject, :mathematics),
      ],
    )
  end
  let(:provider) { build(:provider, accredited_body?: true, sites: [site1, site2]) }

  before do
    stub_omniauth(provider: provider)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider, include: "sites")
    new_course = build(:course, :new, provider: provider)
    stub_api_v2_resource_collection([new_course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_new_resource(new_course)

    stub_api_v2_build_course
    stub_api_v2_build_course(level: course.level)

    stub_api_v2_request(
      "/recruitment_cycles/2020/providers?page[page]=1",
      resource_list_to_jsonapi([provider], meta: { count: 1 }),
    )

    visit signin_path
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

  context "Viewing the course details page" do
    context "When the application open from date is the recruitment cycle start date" do
      let(:course) { build(:course, applications_open_from: recruitment_cycle.application_start_date, provider: provider) }

      scenario "It displays the 'as soon as its open on find' message" do
        expect(course_confirmation_page.details.application_open_from.text).to eq("As soon as the course is on Find (recommended)")
      end
    end

    context "When the provider has a single site" do
      let(:provider) { build(:provider, accredited_body?: true, sites: [build(:site)]) }

      scenario "It displays the help text" do
        expect(course_confirmation_page.details).to have_single_location_help_text
      end
    end

    context "When the provider is accredited" do
      let(:provider) { build(:provider, accredited_body?: true) }

      scenario "It shows the apprenticeship details" do
        expect(course_confirmation_page.details).to have_apprenticeship
        expect(course_confirmation_page.details).not_to have_fee_or_salary
      end
    end

    context "When the provider is not accredited" do
      let(:provider) { build(:provider, accredited_body?: false) }
      let(:accredited_body) { build(:provider) }
      let(:course) { build(:course, provider: provider, accrediting_provider: accredited_body) }

      scenario "It shows the fee or salary details" do
        expect(course_confirmation_page.details).not_to have_apprenticeship
        expect(course_confirmation_page.details).to have_fee_or_salary
      end

      scenario "It shows the accrediting body" do
        expect(course_confirmation_page.details.accredited_body.text).to eq(accredited_body.provider_name)
      end
    end

    context "When the course has nil fields" do
      let(:study_mode) { nil }
      let(:level) { nil }

      scenario "It shows blank for nil fields" do
        expect(course_confirmation_page.details.study_mode.text).to be_blank
        expect(course_confirmation_page.details.level.text).to be_blank
      end
    end

    scenario "it displays the correct information" do
      expect(page.title).to start_with("Check your answers before confirming")

      expect(course_confirmation_page.title).to have_content(
        "Check your answers before confirming",
      )
      expect(course_confirmation_page.details.level.text).to eq("Secondary")
      expect(course_confirmation_page.details.is_send.text).to eq("No")
      expect(course_confirmation_page.details.subjects.text).to include("English")
      expect(course_confirmation_page.details.subjects.text).to include("Mathematics")
      expect(course_confirmation_page.details.age_range.text).to eq("11 to 16")
      expect(course_confirmation_page.details.study_mode.text).to eq("Full time")
      expect(course_confirmation_page.details.locations.text).to eq("Site one Site two")
      expect(course_confirmation_page.details.application_open_from.text).to eq("1 January 2019")
      expect(course_confirmation_page.details.start_date.text).to eq("January 2019")
      expect(course_confirmation_page.details.name.text).to eq("English")
      expect(course_confirmation_page.details.description.text).to eq("PGCE with QTS full time")
      expect(course_confirmation_page.details.entry_requirements.text).to include("Maths GCSE: Taking")
      expect(course_confirmation_page.details.entry_requirements.text).to include("English GCSE: Must have")
      expect(course_confirmation_page.preview.name.text).to include("English")
      expect(course_confirmation_page.preview.description.text).to include("PGCE with QTS full time")
    end
  end

  context "Saving the course" do
    context "Successfully" do
      let(:course_create_request) do
        stub_api_v2_request(
          "/recruitment_cycles/#{course.recruitment_cycle.year}" \
          "/providers/#{provider.provider_code}" \
          "/courses",
          course.to_jsonapi,
          :post,
          200,
        )
      end

      before do
        course.course_code = "A123"
        stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
        course_create_request

        course_confirmation_page.save.click
      end

      scenario "It creates the course on the API" do
        expect(course_create_request).to have_been_made
      end

      scenario "It displays the course page when created" do
        expect(course_page).to be_displayed
      end

      scenario "It displays the success message on the course page" do
        expect(course_page).to have_success_summary
        expect(course_page.success_summary).to have_content("Your course has been created")
        expect(course_page.success_summary).to have_content("Add the rest of your details and publish the course, so that candidates can find and apply to it.")
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
                "title": "You need more cats",
                "detail": "Cats are important",
              },
            ],
          },
          :post,
          200,
        )

        course_confirmation_page.save.click

        expect_course_confirmation_page_to_display_course_information
        expect(course_confirmation_page).to have_content(
          "Cats are important",
        )
      end
    end
  end

  describe "Changing properties" do
    shared_examples "goes to the edit page" do
      it "goes to the edit page" do
        expect(destination_page).to be_displayed
        expect(destination_page).to have_current_path(/goto_confirmation=true/)
        expect(destination_page).to have_current_path(/course%5Blevel%5D=#{course.level}/)
      end
    end

    context "level" do
      let(:destination_page) { PageObjects::Page::Organisations::Courses::NewLevelPage.new }

      before do
        course_confirmation_page.details.edit_level.click
      end

      include_examples "goes to the edit page"
    end

    context "is send" do
      let(:destination_page) { PageObjects::Page::Organisations::Courses::NewLevelPage.new }

      before do
        course_confirmation_page.details.edit_is_send.click
      end

      include_examples "goes to the edit page"
    end

    context "subjects" do
      let(:destination_page) { PageObjects::Page::Organisations::Courses::NewSubjectsPage.new }

      before do
        course_confirmation_page.details.edit_subjects.click
      end

      include_examples "goes to the edit page"
    end

    context "modern languages" do
      let(:subjects_page) { PageObjects::Page::Organisations::Courses::NewSubjectsPage.new }
      let(:languages_page) { PageObjects::Page::Organisations::Courses::NewModernLanguagesPage.new }
      let(:modern_languages_subject) { build(:subject, :modern_languages) }
      let(:russian) { build(:subject, :russian) }
      let(:edit_options) do
        {
          subjects: [modern_languages_subject],
          age_range_in_years: [],
          modern_languages: [russian],
          modern_languages_subject: modern_languages_subject,
        }
      end
      let(:course) do
        build(
          :course,
          provider: provider,
          sites: [site1, site2],
          study_mode: study_mode,
          level: level,
          edit_options: edit_options,
          subjects: [modern_languages_subject, russian],
        )
      end

      before do
        stub_api_v2_build_course(
          level: course.level,
          subjects_ids: [modern_languages_subject.id],
        )
      end

      it "keeps languages checked" do
        course_confirmation_page.details.edit_subjects.click
        subjects_page.continue.click
        expect(languages_page.language_checkbox("Russian")).to be_checked
      end
    end

    context "age range" do
      let(:destination_page) { PageObjects::Page::Organisations::Courses::NewAgeRangePage.new }

      before do
        course_confirmation_page.details.edit_age_range.click
      end

      include_examples "goes to the edit page"
    end

    context "study mode" do
      let(:destination_page) { PageObjects::Page::Organisations::Courses::NewStudyModePage.new }

      before do
        course_confirmation_page.details.edit_study_mode.click
      end

      include_examples "goes to the edit page"
    end

    context "locations page" do
      let(:destination_page) { PageObjects::Page::Organisations::Courses::NewLocationsPage.new }

      before do
        course_confirmation_page.details.edit_locations.click
      end

      include_examples "goes to the edit page"
    end

    context "application open from page" do
      let(:destination_page) { PageObjects::Page::Organisations::Courses::NewApplicationsOpenPage.new }

      before do
        course_confirmation_page.details.edit_application_open_from.click
      end

      include_examples "goes to the edit page"
    end

    context "start date page" do
      let(:destination_page) { PageObjects::Page::Organisations::Courses::NewStartDatePage.new }

      before do
        course_confirmation_page.details.edit_start_date.click
      end

      include_examples "goes to the edit page"
    end

    context "entry requirements page" do
      let(:destination_page) { PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new }

      before do
        course_confirmation_page.details.edit_entry_requirements.click
      end

      include_examples "goes to the edit page"
    end

    context "course outcome page" do
      let(:destination_page) { PageObjects::Page::Organisations::Courses::NewCourseOutcome.new }

      before do
        course_confirmation_page.details.edit_qualifications.click
      end

      include_examples "goes to the edit page"
    end
  end

private

  def expect_course_confirmation_page_to_display_course_information
    expect(course_confirmation_page.title).to have_content(
      "Check your answers before confirming",
    )

    expect(course_confirmation_page.details.level.text).to eq(course.level.to_s.capitalize)
    expect(course_confirmation_page.details.is_send.text).to eq("No")
    expect(course_confirmation_page.details.subjects.text).to include("English")
    expect(course_confirmation_page.details.subjects.text).to include("Mathematics")
    expect(course_confirmation_page.details.age_range.text).to eq("11 to 16")
    expect(course_confirmation_page.details.study_mode.text).to eq("Full time")
    expect(course_confirmation_page.details.locations.text).to eq("Site one Site two")
    expect(course_confirmation_page.details.application_open_from.text).to eq("1 January 2019")
    expect(course_confirmation_page.details.start_date.text).to eq("January 2019")
    expect(course_confirmation_page.details.name.text).to eq("English")
    expect(course_confirmation_page.details.description.text).to eq("PGCE with QTS full time")
    expect(course_confirmation_page.details.entry_requirements.text).to include("Maths GCSE: Taking")
    expect(course_confirmation_page.details.entry_requirements.text).to include("English GCSE: Must have")
    expect(course_confirmation_page.preview.name.text).to include("English")
    expect(course_confirmation_page.preview.description.text).to include("PGCE with QTS full time")
  end
end
