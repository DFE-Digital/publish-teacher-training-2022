require "rails_helper"

feature "Course requirements", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:next_recruitment_cycle) { build(:recruitment_cycle, :next_cycle) }
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

  let(:next_cycle_course) do
    build :course,
          name: "English",
          provider: provider,
          required_qualifications: "Required qualifications",
          personal_qualities: "Personal qualities",
          other_requirements: "Other requirements",
          recruitment_cycle: next_recruitment_cycle
  end

  let(:course_response) do
    course.to_jsonapi(include: %i[sites provider accrediting_provider recruitment_cycle])
  end

  before do
    signed_in_user
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(provider, include: "sites")
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(next_cycle_course, include: "subjects,sites,provider.sites,accrediting_provider")
  end

  let(:course_requirements_page) { PageObjects::Page::Organisations::CourseRequirements.new }

  scenario "submitting with validation errors" do
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}",
      build(:error, :for_course_publish),
      :patch,
      422,
    )

    visit requirements_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)

    fill_in "Personal qualities", with: "foo " * 401
    click_on "Save"

    expect(course_requirements_page.error_flash).to have_content(
      "There is a problem",
    )
    expect(current_path).to eq requirements_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle.year, course.course_code)
  end

  context "when copying course requirements from another course" do
    let(:course_2) do
      build(
        :course,
        name: "Biology",
        provider: provider,
        personal_qualities: "Course 2 personal qualities",
        other_requirements: "Course 2 other requirements",
      )
    end

    let(:course_3) do
      build(
        :course,
        name: "Biology",
        provider: provider,
        other_requirements: "Course 2 other requirements",
      )
    end

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

    scenario "only fields with values are copied if the source was incomplete" do
      course_requirements_page.load_with_course(course_2)
      course_requirements_page.copy_content.copy(course_3)

      [
        "Your changes are not yet saved",
        "Other requirements",
      ].each do |name|
        expect(course_requirements_page.warning_message).to have_content(name)
      end

      [
        "Personal qualities",
      ].each do |name|
        expect(course_requirements_page.warning_message).not_to have_content(name)
      end

      expect(course_requirements_page.personal_qualities.value).to eq(course_2.personal_qualities)
      expect(course_requirements_page.other_requirements.value).to eq(course_2.other_requirements)
    end

    scenario "only personal and other requirements copied over" do
      course_requirements_page.load_with_course(course)
      course_requirements_page.copy_content.copy(course_2)

      [
        "Your changes are not yet saved",
        "Personal qualities",
        "Other requirements",
      ].each do |name|
        expect(course_requirements_page.warning_message).to have_content(name)
      end
      expect(course_requirements_page.warning_message).to_not have_content("Qualifications needed")
    end
  end
end
