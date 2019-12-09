require "rails_helper"

feature "Edit course entry requirements", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:entry_requirements_page) { PageObjects::Page::Organisations::CourseEntryRequirements.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider) }
  let(:edit_options) {
    {
      entry_requirements: %w[must_have_qualification_at_application_time expect_to_achieve_before_training_begins equivalence_test],
    }
  }

  before do
    stub_omniauth
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course)
    entry_requirements_page.load_with_course(course)
  end

  context "a course without required GCSE subjects" do
    let(:course) do
      build(
        :course,
        edit_options: edit_options,
        gcse_subjects_required: [],
        provider: provider,
      )
    end

    scenario "404s when you try to edit entry requirements" do
      expect(page.status_code).to eq(404)
    end
  end

  context "a course with all required subjects (primary)" do
    let(:course) do
      build(
        :course,
        edit_options: edit_options,
        provider: provider,
        maths: "must_have_qualification_at_application_time",
        english: "expect_to_achieve_before_training_begins",
        science: "equivalence_test",
        gcse_subjects_required: %w[maths english science],
      )
    end

    scenario "can cancel changes" do
      click_on "Cancel changes"
      expect(course_details_page).to be_displayed
    end

    scenario "can navigate to the edit screen and back again" do
      course_details_page.load_with_course(course)
      click_on "Change entry requirements"
      expect(entry_requirements_page).to be_displayed
      click_on "Back"
      expect(course_details_page).to be_displayed
    end

    scenario "presents a choice for each subject" do
      expect(entry_requirements_page).to have_maths_requirements
      expect(entry_requirements_page).to have_english_requirements
      expect(entry_requirements_page).to have_science_requirements

      %w[
        maths_requirements
        english_requirements
        science_requirements
      ].each do |subject|
        expect(entry_requirements_page.send(subject)).to have_field("1. Must have the GCSE (least flexible)")
        expect(entry_requirements_page.send(subject)).to have_field("2: Taking the GCSE")
        expect(entry_requirements_page.send(subject)).to have_field("3: Equivalence test")
      end
    end

    scenario "has the correct value selected" do
      expect(entry_requirements_page).to have_maths_requirements
      expect(entry_requirements_page).to have_english_requirements
      expect(entry_requirements_page).to have_science_requirements

      [
        ["maths_requirements", "1. Must have the GCSE (least flexible)"],
        ["english_requirements", "2: Taking the GCSE"],
        ["science_requirements", "3: Equivalence test"],
      ].each do |subject, field_name|
        expect(entry_requirements_page.send(subject)).to have_field(field_name, checked: true)
      end
    end

    scenario "can be updated" do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch, 200
      )

      choose("course_maths_expect_to_achieve_before_training_begins")
      choose("course_english_expect_to_achieve_before_training_begins")
      choose("course_science_expect_to_achieve_before_training_begins")
      click_on "Save"

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content("Your changes have been saved")
      expect(update_course_stub).to have_been_requested
    end
  end

  context "a course without science as a required subject (secondary)" do
    let(:course) do
      build(
        :course,
        edit_options: edit_options,
        provider: provider,
        maths: "must_have_qualification_at_application_time",
        english: "expect_to_achieve_before_training_begins",
        science: "not_set",
        gcse_subjects_required: %w[maths english],
      )
    end

    scenario "presents a choice for only Maths and English" do
      expect(entry_requirements_page).to have_maths_requirements
      expect(entry_requirements_page).to have_english_requirements
      expect(entry_requirements_page).not_to have_science_requirements

      %w[
        maths_requirements
        english_requirements
      ].each do |subject|
        expect(entry_requirements_page.send(subject)).to have_field("1. Must have the GCSE (least flexible)")
        expect(entry_requirements_page.send(subject)).to have_field("2: Taking the GCSE")
        expect(entry_requirements_page.send(subject)).to have_field("3: Equivalence test")
      end
    end

    scenario "can be updated" do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch, 200
      )

      choose("course_maths_expect_to_achieve_before_training_begins")
      choose("course_english_expect_to_achieve_before_training_begins")
      click_on "Save"

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content("Your changes have been saved")
      expect(update_course_stub).to have_been_requested
    end
  end

  context "a course with data that doesn’t align with requirements" do
    let(:course) do
      build(
        :course,
        edit_options: edit_options,
        provider: provider,
        maths: "not_set",
        english: "not_set",
        science: "not_required",
        gcse_subjects_required: %w[maths english science],
      )
    end

    scenario "shows an error if the form is submitted without providing answers" do
      click_on "Save changes"
      expect(entry_requirements_page).to be_displayed

      expect(entry_requirements_page.error_flash)
        .to have_content("You’ll need to correct some information")

      %w[maths english science].each do |s|
        expect(entry_requirements_page.error_flash).to have_content("Pick an option for #{s.titleize}")
        expect(entry_requirements_page).to have_selector("##{s}-error")
      end
    end

    scenario "can be updated" do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch, 200
      )

      choose("course_maths_expect_to_achieve_before_training_begins")
      choose("course_english_expect_to_achieve_before_training_begins")
      choose("course_science_expect_to_achieve_before_training_begins")
      click_on "Save"

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content("Your changes have been saved")
      expect(update_course_stub).to have_been_requested
    end
  end

  def stub_course_request
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}/courses" \
      "/#{course.course_code}",
      course.to_jsonapi,
    )
  end

  def stub_course_details_tab
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}" \
      "?include=subjects,sites,provider.sites,accrediting_provider",
      course.to_jsonapi(include: [:subjects, :sites, :accrediting_provider, :recruitment_cycle, provider: :sites]),
    )
  end
end
