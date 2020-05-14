require "rails_helper"

feature "Edit course outcome", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:outcome_page) { PageObjects::Page::Organisations::CourseOutcome.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course)
    outcome_page.load_with_course(course)
  end

  context "a course that offers QTS" do
    let(:course) do
      build(
        :course,
        provider: provider,
      )
    end

    scenario "can cancel changes" do
      click_on "Cancel changes"
      expect(course_details_page).to be_displayed
    end

    scenario "can navigate to the edit screen and back again" do
      course_details_page.load_with_course(course)
      click_on "Change outcome"
      expect(outcome_page).to be_displayed
      click_on "Back"
      expect(course_details_page).to be_displayed
    end

    scenario "presents a choice for each qualification" do
      expect(outcome_page).to have_qualification_fields
      expect(outcome_page.qualification_fields)
        .to have_selector('[for="course_qualification_qts"]', text: "QTS")
      expect(outcome_page.qualification_fields)
        .to have_selector('[for="course_qualification_pgce_with_qts"]', text: "PGCE with QTS")
      expect(outcome_page.qualification_fields)
        .to have_selector('[for="course_qualification_pgde_with_qts"]', text: "PGDE with QTS")
    end

    scenario "has the correct value selected" do
      expect(outcome_page.qualification_fields)
        .to have_field("course_qualification_pgce_with_qts", checked: true)
    end

    scenario "can be updated" do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch,
        200,
      )

      choose("course_qualification_qts")
      click_on "Save"

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content("Your changes have been saved")
      expect(update_course_stub).to have_been_requested
    end
  end

  context "a further education course that doesn’t offer QTS" do
    let(:course) do
      build(
        :course,
        level: :further_education,
        qualification: "pgde",
        provider: provider,
      )
    end

    scenario "presents a choice for each qualification" do
      expect(outcome_page).to have_qualification_fields
      expect(outcome_page.qualification_fields)
        .to have_selector('[for="course_qualification_pgce"]', text: "PGCE only")
      expect(outcome_page.qualification_fields)
        .to have_selector('[for="course_qualification_pgde"]', text: "PGDE only")
    end

    scenario "has the correct value selected" do
      expect(outcome_page.qualification_fields)
        .to have_field("course_qualification_pgde", checked: true)
    end
  end

  context "a course with bad data" do
    let(:course) do
      build(
        :course,
        provider: provider,
        qualification: "something_else",
      )
    end

    scenario "shows an error if the form is submitted without providing answers" do
      click_on "Save"
      expect(outcome_page).to be_displayed

      expect(outcome_page.error_flash)
        .to have_content("You’ll need to correct some information")

      expect(outcome_page.error_flash).to have_content("Pick an outcome")
      expect(outcome_page).to have_selector("#qualification-error")
    end

    scenario "shows validation errors returned by backend" do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        build(:error, :for_course_outcome),
        :patch,
        422,
      )

      choose("course_qualification_qts")
      click_on "Save"
      expect(outcome_page).to be_displayed

      expect(outcome_page.error_flash)
        .to have_content("You’ll need to correct some information")

      expect(outcome_page.error_flash).to have_content("Qualification error")
      expect(outcome_page).to have_selector("#qualification-error")
      expect(update_course_stub).to have_been_requested
    end
  end
end
