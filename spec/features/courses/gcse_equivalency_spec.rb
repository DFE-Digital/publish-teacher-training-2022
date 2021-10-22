require "rails_helper"

feature "GCSE equivalency requirements", type: :feature do
  let(:course_page) { PageObjects::Page::Organisations::Course.new }
  let(:gcse_requirements_page) { PageObjects::Page::Organisations::Courses::GcseRequirementsPage.new }

  let(:provider) { build(:provider, recruitment_cycle: recruitment_cycle) }
  let(:course) { build(:course, provider: provider, recruitment_cycle: recruitment_cycle, additional_gcse_equivalencies: nil) }
  let(:course2) { build(:course, provider: provider, recruitment_cycle: recruitment_cycle, level: "primary", accept_pending_gcse: false, accept_gcse_equivalency: false, additional_gcse_equivalencies: nil) }
  let(:course3) do
    build(:course, provider: provider, recruitment_cycle: recruitment_cycle, level: "secondary", accept_pending_gcse: true, accept_gcse_equivalency: true,
                   accept_english_gcse_equivalency: true, accept_maths_gcse_equivalency: true, accept_science_gcse_equivalency: nil, additional_gcse_equivalencies: "Cycling Proficiency")
  end
  let(:recruitment_cycle) { build(:recruitment_cycle, :next_cycle) }
  let(:provider_for_copy_from_list) do
    build(:provider, courses: [course, course2, course3], provider_code: "A0")
  end

  before do
    signed_in_user(provider: provider)
    stub_api_v2_resource(provider, include: "sites")
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(course, include: "provider")
    stub_api_v2_resource(course2, include: "provider")
    stub_api_v2_resource(course2, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course3, include: "provider")
    stub_api_v2_resource(course3, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}",
      course.to_jsonapi,
      :patch,
      200,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}/gcses-pending-or-equivalency-tests", \
      course2.to_jsonapi,
      :get,
      200,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "?include=courses.accrediting_provider",
      provider_for_copy_from_list.to_jsonapi(include: %i[courses accrediting_provider]),
    )
  end

  scenario "a provider completes the gcse equivalency requirements section" do
    course_page.load_with_course(course)
    visit_description_page(course)
    click_link "Enter GCSE and equivalency test requirements"

    gcse_requirements_page.save.click
    expect(page).to have_content("Select if you consider candidates with pending GCSEs")
    expect(page).to have_content("Select if you consider candidates with pending equivalency tests")

    choose "Yes", name: "courses_gcse_requirements_form[accept_pending_gcse]"
    choose "Yes", name: "courses_gcse_requirements_form[accept_gcse_equivalency]"
    gcse_requirements_page.save.click
    expect(page).to have_content("Enter details about equivalency tests")
    expect(page).to have_content("Select if you accept equivalency tests in English or maths")

    check "English"
    check "Maths"
    fill_in "Details about equivalency tests you offer or accept", with: "Cycling Proficiency"
    gcse_requirements_page.save.click

    expect(page).to have_current_path provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle.year,
      course.course_code,
    )
  end

  scenario "a provider views course pages with different GCSE requirements" do
    course_page.load_with_course(course2)

    expect(page).to have_content("Grade 4 (C) or above in English, maths and science")
    expect(page).to have_content("Candidates with pending GCSEs will not be considered")
    expect(page).to have_content("Equivalency tests will not be accepted")
  end

  scenario "a provider views course pages with different GCSE requirements" do
    course_page.load_with_course(course3)

    expect(page).to have_content("Grade 4 (C) or above in English and maths")
    expect(page).to have_content("Candidates with pending GCSEs will be considered")
    expect(page).to have_content("Equivalency tests will be accepted in English or maths")
    expect(page).to have_content("Cycling Proficiency")
  end

  scenario "a provider has completed the pending GCSE & equivalency requirements and sees their answer pre-populated on the gcse requirements page" do
    course_page.load_with_course(course3)
    visit_gcse_requirements_page

    expect(gcse_requirements_page.pending_gcse_yes_radio).to be_checked
    expect(gcse_requirements_page.gcse_equivalency_yes_radio).to be_checked
    expect(gcse_requirements_page.english_equivalency).to be_checked
    expect(gcse_requirements_page.maths_equivalency).to be_checked
    expect(gcse_requirements_page.additional_requirements).to have_content("Cycling Proficiency")
  end

  scenario "a provider copies gcse data from another course" do
    course_page.load_with_course(course)
    visit_gcse_requirements_page
    gcse_requirements_page.copy_content.copy(course3)

    [
      "Your changes are not yet saved",
      "Accept pending GCSE",
      "Accept GCSE equivalency",
      "Accept English GCSE equivalency",
      "Accept Maths GCSE equivalency",
      "Additional GCSE equivalencies",
    ].each do |name|
      expect(gcse_requirements_page.warning_message).to have_content(name)
    end

    expect(gcse_requirements_page.pending_gcse_yes_radio).to be_checked

    expect(gcse_requirements_page.gcse_equivalency_yes_radio).to be_checked
    expect(gcse_requirements_page.english_equivalency).to be_checked
    expect(gcse_requirements_page.maths_equivalency).to be_checked
    expect(gcse_requirements_page.additional_requirements.text).to eq course3.additional_gcse_equivalencies
  end

  def visit_description_page(course)
    visit provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle.year,
      course.course_code,
    )
  end

  def visit_gcse_requirements_page
    visit gcses_pending_or_equivalency_tests_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course3.recruitment_cycle.year,
      course3.course_code,
    )
  end
end
