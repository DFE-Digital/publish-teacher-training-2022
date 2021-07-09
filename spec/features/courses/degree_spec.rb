require "rails_helper"

feature "degree requirements", type: :feature do
  let(:course_page) { PageObjects::Page::Organisations::Course.new }
  let(:start_page) { PageObjects::Page::Organisations::Courses::Degrees::StartPage.new }
  let(:grade_page) { PageObjects::Page::Organisations::Courses::Degrees::GradePage.new }
  let(:subject_requirements_page) { PageObjects::Page::Organisations::Courses::Degrees::SubjectRequirementsPage.new }

  let(:provider) { build(:provider, recruitment_cycle: recruitment_cycle) }
  let(:course) { build(:course, provider: provider, recruitment_cycle: recruitment_cycle, degree_grade: nil) }
  let(:course2) { build(:course, provider: provider, recruitment_cycle: recruitment_cycle, degree_grade: "not_required") }
  let(:course3) { build(:course, provider: provider, recruitment_cycle: recruitment_cycle, degree_grade: "two_one") }
  let(:course4) { build(:course, provider: provider, recruitment_cycle: recruitment_cycle, additional_degree_subject_requirements: true, degree_subject_requirements: "Maths A level") }
  let(:course5) { build(:course, provider: provider, recruitment_cycle: recruitment_cycle, degree_grade: "two_two") }
  let(:course6) { build(:course, provider: provider, recruitment_cycle: recruitment_cycle, degree_grade: "third_class") }
  let(:primary_course) { build(:course, provider: provider, recruitment_cycle: recruitment_cycle, degree_grade: nil, level: "primary") }
  let(:recruitment_cycle) { build(:recruitment_cycle, :next_cycle) }

  before do
    signed_in_user(provider: provider)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course, include: "provider")
    stub_api_v2_resource(course2, include: "provider")
    stub_api_v2_resource(course2, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course3, include: "provider")
    stub_api_v2_resource(course3, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course4, include: "provider")
    stub_api_v2_resource(course4, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course5, include: "provider")
    stub_api_v2_resource(course5, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course6, include: "provider")
    stub_api_v2_resource(course6, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(primary_course, include: "provider")
    stub_api_v2_resource(primary_course, include: "provider")
    stub_api_v2_resource(primary_course, include: "subjects,sites,provider.sites,accrediting_provider")
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
      "/courses/#{course.course_code}/degree", \
      course2.to_jsonapi,
      :get,
      200,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{primary_course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{primary_course.course_code}", \
      primary_course.to_jsonapi,
      :get,
      200,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{primary_course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{primary_course.course_code}", \
      primary_course.to_jsonapi,
      :patch,
      200,
    )
  end

  scenario "a provider completes the degree requirements section and provides a classification" do
    course_page.load_with_course(course)
    visit_description_page(course)
    click_link "Enter degree requirements"
    choose "Yes"
    start_page.save.click
    choose "2:1 or above (or equivalent)"
    grade_page.save.click
    choose "Yes"
    fill_in "Degree subject requirements", with: "Must have a physics A level."
    subject_requirements_page.save.click
    expect(page).to have_current_path provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle.year,
      course.course_code,
    )
  end

  scenario "a provider completes the degree requirements section and does not provide a classification" do
    course_page.load_with_course(course)
    visit_description_page(course)
    click_link "Enter degree requirements"
    choose "No"
    start_page.save.click
    choose "Yes"
    fill_in "Degree subject requirements", with: "Must have a physics A level."
    subject_requirements_page.save.click
    expect(page).to have_current_path provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle.year,
      course.course_code,
    )
  end

  scenario "a provider chooses to have a required grade for a primary course" do
    course_page.load_with_course(primary_course)
    visit_description_page(primary_course)
    click_link "Enter degree requirements"
    choose "Yes"
    start_page.save.click
    choose "2:1 or above (or equivalent)"
    grade_page.save.click
    expect(page).to have_current_path provider_recruitment_cycle_course_path(
      provider.provider_code,
      primary_course.recruitment_cycle.year,
      primary_course.course_code,
    )
  end

  scenario "a provider chooses not to have a required grade for a primary course" do
    course_page.load_with_course(primary_course)
    visit_description_page(primary_course)
    click_link "Enter degree requirements"
    choose "No"
    start_page.save.click
    expect(page).to have_current_path provider_recruitment_cycle_course_path(
      provider.provider_code,
      primary_course.recruitment_cycle.year,
      primary_course.course_code,
    )
  end

  scenario "a provider has completed the degree section and sees their answer pre-populated on the degree page" do
    course_page.load_with_course(course2)
    visit_start_page

    expect(start_page.no_radio).to be_checked
  end

  scenario "a provider has completed the degree section and sees their two_one answer pre-populated on the degree grade page" do
    course_page.load_with_course(course3)
    visit_grade_page(course3)

    expect(grade_page.two_one).to be_checked
  end

  scenario "a provider has completed the degree section and sees their two_two answer pre-populated on the degree grade page" do
    course_page.load_with_course(course5)
    visit_grade_page(course5)

    expect(grade_page.two_two).to be_checked
  end

  scenario "a provider has completed the degree section and sees their third_class answer pre-populated on the degree grade page" do
    course_page.load_with_course(course6)
    visit_grade_page(course6)

    expect(grade_page.third_class).to be_checked
  end

  scenario "a provider has completed the degree section and sees their answer pre-populated on the degree subject requirements page" do
    course_page.load_with_course(course4)
    visit_subject_requirements_page

    expect(subject_requirements_page.yes_radio).to be_checked
    expect(subject_requirements_page.requirements.text).to eq "Maths A level"
  end

  def visit_description_page(course)
    visit provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle.year,
      course.course_code,
    )
  end

  def visit_start_page
    visit degrees_start_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course2.recruitment_cycle.year,
      course2.course_code,
    )
  end

  def visit_grade_page(course)
    visit degrees_grade_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle.year,
      course.course_code,
    )
  end

  def visit_subject_requirements_page
    visit degrees_subject_requirements_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course4.recruitment_cycle.year,
      course4.course_code,
    )
  end
end
