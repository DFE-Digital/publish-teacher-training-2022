require "rails_helper"

feature "About course", type: :feature do
  let(:current_recruitment_cycle) { build :recruitment_cycle }
  let(:provider) do
    build(
      :provider,
      accredited_body?: false,
      provider_code: "A0",
      provider_type: "lead_school",
    )
  end

  let(:course) do
    build(
      :course,
      name: "English",
      provider: provider,
      about_course: "About course",
      interview_process: "Interview process",
      how_school_placements_work: "How teaching placements work",
      recruitment_cycle: current_recruitment_cycle,
      sites: [site1, site2],
    )
  end

  let(:site1) { build(:site, london_borough: "Westminster") }
  let(:site2) { build(:site, travel_to_work_area: "Brighton") }

  let(:course_response) do
    course.to_jsonapi(
      include: %i[sites provider accrediting_provider recruitment_cycle],
    )
  end

  before do
    signed_in_user
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,courses.accrediting_provider")
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(provider)
  end

  let(:about_course_page) { PageObjects::Page::Organisations::CourseAbout.new }

  context "provider is not a university" do
    scenario "viewing the about courses page" do
      stub_api_v2_resource(course, method: :patch)

      visit provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
      click_on "About this course"

      expect(current_path).to eq about_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)

      expect(about_course_page.caption).to have_content(
        "#{course.name} (#{course.course_code})",
      )
      expect(about_course_page.title).to have_content(
        "About this course",
      )
      expect(about_course_page).to have_enrichment_form
      expect(about_course_page.about_textarea.value).to eq(
        course.about_course,
      )
      expect(about_course_page.interview_process_textarea.value).to eq(
        course.interview_process,
      )
      expect(about_course_page.how_school_placements_work_textarea.value).to eq(
        course.how_school_placements_work,
      )
      expect(page).to have_content("This course has placement schools in Westminster and Brighton.")

      fill_in "About this course", with: "Something interesting about this course"
      fill_in "How school placements work", with: "Something about how teaching placements work"
      click_on "Save"

      expect(about_course_page.flash).to have_content(
        "Your changes have been saved",
      )
      expect(current_path).to eq provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
    end
  end

  context "provider is a university" do
    let(:provider2) do
      build(
        :provider,
        accredited_body?: false,
        provider_code: "A0",
        provider_type: "university",
      )
    end

    let(:course2) do
      build(
        :course,
        name: "English",
        provider: provider2,
        about_course: "About course",
        interview_process: "Interview process",
        how_school_placements_work: "How teaching placements work",
        recruitment_cycle: current_recruitment_cycle,
        sites: [site1, site2],
      )
    end

    before do
      signed_in_user
      stub_api_v2_resource(current_recruitment_cycle)
      stub_api_v2_resource(course2, include: "subjects,sites,provider.sites,courses.accrediting_provider")
      stub_api_v2_resource(course2, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(provider2, include: "courses.accrediting_provider")
      stub_api_v2_resource(provider2)
    end

    scenario "viewing the about courses page" do
      stub_api_v2_resource(course, method: :patch)

      visit provider_recruitment_cycle_course_path(provider2.provider_code, course2.recruitment_cycle_year, course2.course_code)
      click_on "About this course"

      expect(page).to have_content("This university is based in Westminster and Brighton,")
    end
  end

  scenario "submitting with validation errors" do
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}",
      build(:error, :for_course_publish),
      :patch,
      422,
    )

    visit about_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)

    fill_in "About this course", with: "foo " * 401
    click_on "Save"

    expect(about_course_page.error_flash).to have_content(
      "You’ll need to correct some information.",
    )
    expect(current_path).to eq about_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
  end

  context "when a provider has no self accredited courses (for example a School Direct provider)" do
    let(:course_1) { build :course, provider: provider, name: "Computing", accrediting_provider: accredited_body }
    let(:course_2) { build :course, name: "Drama", accrediting_provider: accredited_body }
    let(:courses)  { [course_2] }
    let(:accredited_body) { build :provider, accredited_body?: true, provider_code: "A1" }
    let(:provider) { build :provider, courses: courses, accredited_body?: false, provider_code: "A0" }

    scenario "viewing the about courses page" do
      visit about_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)

      expect(about_course_page.caption).to have_content(
        "#{course.name} (#{course.course_code})",
      )
    end
  end

  context "when copying course requirements from another course" do
    let(:course_2) do
      build :course,
            name: "Biology",
            provider: provider,
            about_course: "Course 2 - About course",
            interview_process: "Course 2 - Interview process",
            how_school_placements_work: "Course 2 - How teaching placements work"
    end

    let(:course_3) do
      build :course,
            name: "Biology",
            provider: provider,
            about_course: "Course 3 - About course"
    end

    let(:provider_for_copy_from_list) do
      build :provider,
            courses: [course, course_2, course_3],
            provider_code: provider.provider_code
    end

    before do
      stub_api_v2_resource(course_2, include: "sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(course_2, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(course_3, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(provider_for_copy_from_list, include: "courses.accrediting_provider")
    end

    scenario "all fields get copied if all were present" do
      about_course_page.load_with_course(course)
      about_course_page.copy_content.copy(course_2)

      [
        "Your changes are not yet saved",
        "About the course",
        "Interview process",
        "How school placements work",
      ].each do |name|
        expect(about_course_page.warning_message).to have_content(name)
      end

      expect(about_course_page.about_textarea.value).to eq(course_2.about_course)
      expect(about_course_page.interview_process_textarea.value).to eq(course_2.interview_process)
      expect(about_course_page.how_school_placements_work_textarea.value).to eq(course_2.how_school_placements_work)
    end

    scenario "only fields with values are copied if the source was incomplete" do
      about_course_page.load_with_course(course_2)
      about_course_page.copy_content.copy(course_3)

      [
        "Your changes are not yet saved",
        "About the course",
      ].each do |name|
        expect(about_course_page.warning_message).to have_content(name)
      end

      [
        "Interview process",
        "How teaching placements work",
      ].each do |name|
        expect(about_course_page.warning_message).not_to have_content(name)
      end

      expect(about_course_page.about_textarea.value).to eq(course_3.about_course)
      expect(about_course_page.interview_process_textarea.value).to eq(course_2.interview_process)
      expect(about_course_page.how_school_placements_work_textarea.value).to eq(course_2.how_school_placements_work)
    end
  end
end
