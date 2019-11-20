require "rails_helper"

feature "Course requirements", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) do
    build(:provider, provider_code: "A0")
  end

  let(:course) do
    build :course,
          name: "English",
          provider: provider,
          required_qualifications: "Required qualifications",
          personal_qualities: "Personal qualities",
          other_requirements: "Other requirements",
          recruitment_cycle: current_recruitment_cycle
  end

  let(:course_response) do
    course.to_jsonapi(include: %i[sites provider accrediting_provider recruitment_cycle])
  end

  before do
    stub_omniauth
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
  end

  let(:course_requirements_page) { PageObjects::Page::Organisations::CourseRequirements.new }

  scenario "viewing the courses requirements page" do
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}",
      course_response,
      :patch, 200
    )
    visit provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
    click_on "Requirements and eligibility"

    expect(current_path).to eq requirements_provider_recruitment_cycle_course_path("A0", course.recruitment_cycle_year, course.course_code)

    expect(course_requirements_page.caption).to have_content(
      "#{course.name} (#{course.course_code})",
    )
    expect(course_requirements_page.title).to have_content(
      "Requirements and eligibility",
    )
    expect(course_requirements_page).to have_enrichment_form
    expect(course_requirements_page.required_qualifications.value).to eq(
      course.required_qualifications,
    )
    expect(course_requirements_page.personal_qualities.value).to eq(
      course.personal_qualities,
    )
    expect(course_requirements_page.other_requirements.value).to eq(
      course.other_requirements,
    )

    fill_in "Qualifications needed", with: "Something about the qualifications required for this course"
    fill_in "Personal qualities (optional)", with: "Something about the personal qualities required for this course"
    fill_in "Other requirements (optional)", with: "Something about the other requirements required for this course"

    click_on "Save"

    expect(course_requirements_page.flash).to have_content(
      "Your changes have been saved",
    )

    expect(current_path).to eq provider_recruitment_cycle_course_path("A0", course.recruitment_cycle.year, course.course_code)
  end

  scenario "submitting with validation errors" do
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}",
      build(:error, :for_course_publish),
      :patch, 422
    )

    visit requirements_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)

    fill_in "Qualifications needed", with: "foo " * 401
    click_on "Save"

    expect(course_requirements_page.error_flash).to have_content(
      "You’ll need to correct some information.",
    )
    expect(current_path).to eq requirements_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle.year, course.course_code)
  end

  context "when copying course requirements from another course" do
    let(:course_2) {
      build(
        :course,
        name: "Biology",
        provider: provider,
        required_qualifications: "Course 2 required qualifications",
        personal_qualities: "Course 2 personal qualities",
        other_requirements: "Course 2 other requirements",
      )
    }

    let(:course_3) {
      build(
        :course,
        name: "Biology",
        provider: provider,
        required_qualifications: "Required qualifications",
      )
    }

    let(:provider_for_copy_from_list) do
      build(:provider, courses: [course, course_2, course_3], provider_code: "A0")
    end

    before do
      stub_api_v2_resource(course_2, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(course_3, include: "subjects,sites,provider.sites,accrediting_provider")

      stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "?include=courses.accrediting_provider",
        provider_for_copy_from_list.to_jsonapi(include: %i[courses accrediting_provider]),
      )
    end

    scenario "all fields get copied if all were present" do
      course_requirements_page.load_with_course(course)
      course_requirements_page.copy_content.copy(course_2)

      [
        "Your changes are not yet saved",
        "Qualifications needed",
        "Personal qualities",
        "Other requirements",
      ].each do |name|
        expect(course_requirements_page.warning_message).to have_content(name)
      end

      expect(course_requirements_page.required_qualifications.value).to eq(course_2.required_qualifications)
      expect(course_requirements_page.personal_qualities.value).to eq(course_2.personal_qualities)
      expect(course_requirements_page.other_requirements.value).to eq(course_2.other_requirements)
    end

    scenario "only fields with values are copied if the source was incomplete" do
      course_requirements_page.load_with_course(course_2)
      course_requirements_page.copy_content.copy(course_3)

      [
        "Your changes are not yet saved",
        "Qualifications needed",
      ].each do |name|
        expect(course_requirements_page.warning_message).to have_content(name)
      end

      [
        "Personal qualities",
        "Other requirements",
      ].each do |name|
        expect(course_requirements_page.warning_message).not_to have_content(name)
      end

      expect(course_requirements_page.required_qualifications.value).to eq(course_3.required_qualifications)
      expect(course_requirements_page.personal_qualities.value).to eq(course_2.personal_qualities)
      expect(course_requirements_page.other_requirements.value).to eq(course_2.other_requirements)
    end
  end
end
