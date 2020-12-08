require "rails_helper"

feature "Course salary", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) do
    build(:provider, provider_code: "A0")
  end

  let(:course) do
    build :course,
          name: "English",
          provider: provider,
          course_length: "OneYear",
          salary_details: "Salary details",
          funding_type: "salary",
          recruitment_cycle: current_recruitment_cycle
  end

  before do
    signed_in_user
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
  end

  let(:course_salary_page) { PageObjects::Page::Organisations::CourseSalary.new }

  scenario "viewing the courses salary page" do
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}",
      course.to_jsonapi,
      :patch,
      200,
    )
    visit provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)

    click_on "Course length and salary"

    expect(current_path).to eq salary_provider_recruitment_cycle_course_path("A0", course.recruitment_cycle_year, course.course_code)

    expect(course_salary_page.caption).to have_content(
      "#{course.name} (#{course.course_code})",
    )
    expect(course_salary_page.title).to have_content(
      "Course length and salary",
    )
    expect(course_salary_page).to have_enrichment_form
    expect(course_salary_page.course_length_one_year).to be_checked
    expect(course_salary_page.course_length_two_years).to_not be_checked
    expect(course_salary_page.course_length_other_length.value).to eq("")
    expect(course_salary_page.course_salary_details.value).to eq(
      course.salary_details,
    )

    choose "2 years"
    fill_in "Salary", with: "Test salary details"
    click_on "Save"

    expect(course_salary_page.flash).to have_content(
      "Your changes have been saved",
    )

    expect(current_path).to eq provider_recruitment_cycle_course_path("A0", course.recruitment_cycle_year, course.course_code)
  end

  scenario "submitting with validation errors" do
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}",
      build(:error, :for_course_publish),
      :patch,
      422,
    )

    visit salary_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)

    fill_in "Salary", with: "foo " * 401
    click_on "Save"

    expect(course_salary_page.error_flash).to have_content(
      "You’ll need to correct some information.",
    )
    expect(current_path).to eq salary_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
  end

  context "when copying course salary from another course" do
    let(:course_2) do
      build :course,
            name: "Biology",
            provider: provider,
            course_length: "TwoYears",
            salary_details: "Course 2 salary details",
            funding: "salary",
            recruitment_cycle: current_recruitment_cycle
    end

    let(:course_3) do
      build :course,
            name: "Biology",
            provider: provider,
            course_length: "TwoYears",
            funding: "salary",
            recruitment_cycle: current_recruitment_cycle
    end

    let(:provider_for_copy_from_list) do
      build(:provider, provider_code: "A0", courses: [course, course_2, course_3])
    end

    before do
      stub_api_v2_resource(course_2, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(course_3, include: "subjects,sites,provider.sites,accrediting_provider")

      stub_api_v2_request(
        "/recruitment_cycles/#{course_2.recruitment_cycle.year}" \
        "/providers/A0" \
        "?include=courses.accrediting_provider",
        provider_for_copy_from_list.to_jsonapi(include: %i[courses accrediting_provider]),
      )
    end

    scenario "all fields get copied if all were present" do
      course_salary_page.load_with_course(course)
      course_salary_page.copy_content.copy(course_2)

      [
        "Your changes are not yet saved",
        "Course length",
        "Salary details",
      ].each do |name|
        expect(course_salary_page.warning_message).to have_content(name)
      end

      expect(course_salary_page.course_length_one_year).to_not be_checked
      expect(course_salary_page.course_length_two_years).to be_checked
      expect(course_salary_page.course_salary_details.value).to eq(course_2.salary_details)
    end

    scenario "only fields with values are copied if the source was incomplete" do
      course_salary_page.load_with_course(course_2)
      course_salary_page.copy_content.copy(course_3)

      [
        "Your changes are not yet saved",
        "Course length",
      ].each do |name|
        expect(course_salary_page.warning_message).to have_content(name)
      end

      [
        "Salary details",
      ].each do |name|
        expect(course_salary_page.warning_message).not_to have_content(name)
      end

      expect(course_salary_page.course_length_one_year).to_not be_checked
      expect(course_salary_page.course_length_two_years).to be_checked
      expect(course_salary_page.course_salary_details.value).to eq(course_2.salary_details)
    end
  end
end
