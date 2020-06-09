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
  let(:modern_languages) { build(:subject, :modern_languages) }
  let(:subjects) { [english, biology, modern_languages] }
  let(:selected_subjects) { [] }
  let(:edit_options) do
    {
      subjects: subjects,
      age_range_in_years: [],
      modern_languages: [build(:subject, :russian)],
      modern_languages_subject: modern_languages,
    }
  end
  let(:user) { build(:user) }
  let(:course) do
    build(
      :course,
      :new,
      subjects: selected_subjects,
      provider: provider,
      level: level,
      gcse_subjects_required_using_level: true,
      edit_options: edit_options,
      applications_open_from: DateTime.new(2019).utc.iso8601,
      study_mode: "full_time",
      accrediting_provider: build(:provider),
    )
  end

  let(:access_request) { create(:access_request) }

  before do
    stub_omniauth(user: user)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider.recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_new_resource(course)
    stub_api_v2_build_course
    stub_api_v2_build_course
    stub_api_v2_resource_collection([access_request])

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
        new_subjects_page.subordinate_subject_details.click
        new_subjects_page.subordinate_subjects_fields.select(biology.subject_name).click
        new_subjects_page.continue.click
      end

      scenario "sends user to new outcome page" do
        expect(next_step_page).to be_displayed
      end

      it_behaves_like "a course creation page"
    end

    context "PE subject" do
      context "as an admin user" do
        let(:user) { create(:user, :admin) }

        it "should not have guidance on adding pe via a google form" do
          expect(new_subjects_page.google_form_link.text).to eq("")
        end
      end
    end

    context "subjects field" do
      context "as a non-admin user" do
        it "should have guidance on adding pe via a google form" do
          expect(new_subjects_page.google_form_link.text).to start_with("Adding a Physical education course?")
        end
      end
    end

    context "selecting the modern language subject" do
      let(:selected_subjects) { [modern_languages] }

      scenario "sends user to modern languages" do
        stub_api_v2_build_course(subjects_ids: [modern_languages.id])
        visit_new_subjects_page(goto_confirmation: true)

        new_subjects_page.subjects_fields.select(modern_languages.subject_name).click
        new_subjects_page.continue.click

        expect(page).to have_current_path(
          new_provider_recruitment_cycle_courses_modern_languages_path(
            provider.provider_code,
            provider.recruitment_cycle.year,
            course: { subjects_ids: [modern_languages.id] },
            goto_confirmation: true,
          ),
        )
      end
    end
  end

  context "with a primary course" do
    let(:level) { :primary }
    scenario "Only displays the master subject field" do
      expect(new_subjects_page).to have_subjects_fields
      expect(new_subjects_page).not_to have_subordinate_subject_details
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

      scenario "error flash" do
        new_subjects_page.continue.click
        expect(new_subjects_page.error_flash.text).to include("Subjects Invalid")
      end

      scenario "inline error messages" do
        new_subjects_page.continue.click
        expect(new_subjects_page.error_messages.text).to include("Error: Subjects Invalid")
      end
    end
  end

  context "Page title" do
    context "For a primary course" do
      let(:level) { :primary }

      scenario "It displays the correct title" do
        expect(page.title).to start_with("Pick a primary subject")
        expect(new_subjects_page.title.text).to eq("Pick a primary subject")
      end
    end

    context "For a secondary course" do
      let(:level) { :secondary }

      scenario "It displays the correct title" do
        expect(page.title).to start_with("Pick a secondary subject")
        expect(new_subjects_page.title.text).to eq("Pick a secondary subject")
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
