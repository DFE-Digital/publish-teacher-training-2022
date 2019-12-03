require "rails_helper"

feature "New course level", type: :feature do
  let(:new_subjects_page) do
    PageObjects::Page::Organisations::Courses::NewSubjectsPage.new
  end
  let(:next_step_page) do
    PageObjects::Page::Organisations::Courses::NewAgeRangePage.new
  end
  let(:provider) { build(:provider) }
  let(:english) { build(:subject, :english) }
  let(:biology) { build(:subject, :biology) }
  let(:subjects) { [english, biology] }
  let(:edit_options) { { subjects: subjects, age_range_in_years: [] } }
  let(:course) do
    build(:course,
          :new,
          provider: provider,
          level: level,
          gcse_subjects_required_using_level: true,
          edit_options: edit_options,
          applications_open_from: DateTime.new(2019).utc.iso8601,
          study_mode: "full_time")
  end

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider.recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_new_resource(course)
    stub_api_v2_build_course
    stub_api_v2_build_course

    visit "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}" \
    "/courses/subjects/new"
  end

  context "with a secondary course" do
    let(:level) { :secondary }
    context "Selecting master subject" do
      let(:selected_fields) { { subjects_ids: [english.id] } }
      let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

      before do
        build_course_with_selected_value_request
        new_subjects_page.subjects_fields.select(english.subject_name).click
        new_subjects_page.continue.click
      end

      scenario "sends user to new outcome page" do
        expect(next_step_page).to be_displayed
      end

      it_behaves_like "a course creation page"
    end

    context "Selecting master & subordinate subject" do
      let(:selected_fields) { { subjects_ids: [english.id, biology.id] } }
      let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

      before do
        build_course_with_selected_value_request
        new_subjects_page.subjects_fields.select(english.subject_name).click
        new_subjects_page.subordinate_subject_accordion.click
        new_subjects_page.subordinate_subjects_fields.select(biology.subject_name).click
        new_subjects_page.continue.click
      end

      scenario "sends user to new outcome page" do
        expect(next_step_page).to be_displayed
      end

      it_behaves_like "a course creation page"
    end
  end

  context "with a primary course" do
    let(:level) { :primary }
    scenario "Only displays the master subject field" do
      expect(new_subjects_page).to have_subjects_fields
      expect(new_subjects_page).not_to have_subordinate_subject_accordion
    end

    context "Selecting master subject" do
      let(:selected_fields) { { subjects_ids: [english.id] } }
      let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

      before do
        build_course_with_selected_value_request
        new_subjects_page.subjects_fields.select(english.subject_name).click
        new_subjects_page.continue.click
      end

      scenario "sends user to new outcome page" do
        expect(next_step_page).to be_displayed
      end

      it_behaves_like "a course creation page"
    end

    context "Error handling" do
      let(:level) { :primary }
      let(:course) do
        c = build(:course, :new, provider: provider, level: level, gcse_subjects_required_using_level: true, edit_options: edit_options)
        c.errors.add(:subjects, "Invalid")
        c
      end

      before do
        stub_api_v2_build_course(subjects_ids: [nil])
      end

      scenario do
        new_subjects_page.continue.click
        expect(new_subjects_page.error_flash.text).to include("Subjects Invalid")
      end
    end

    scenario "sends user back to course confirmation" do
      stub_api_v2_build_course(subjects_ids: [english.id])
      visit_new_subjects_page(goto_confirmation: true)

      new_subjects_page.subjects_fields.select(english.subject_name).click
      new_subjects_page.continue.click

      expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
    end
  end

  context "Page title" do
    context "For a primary course" do
      let(:level) { :primary }

      scenario "It displays the correct title" do
        expect(page.title).to start_with("Select a primary subject")
        expect(new_subjects_page.title.text).to eq("Select a primary subject")
      end
    end

    context "For a secondary course" do
      let(:level) { :secondary }

      scenario "It displays the correct title" do
        expect(page.title).to start_with("Select a secondary subject")
        expect(new_subjects_page.title.text).to eq("Select a secondary subject")
      end
    end
  end

private

  def visit_new_subjects_page(**query_params)
    visit new_provider_recruitment_cycle_courses_subjects_path(
      provider.provider_code,
      provider.recruitment_cycle.year,
      query_params,
    )
  end
end
