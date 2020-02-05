require "rails_helper"

feature "new modern language", type: :feature do
  let(:back_new_modern_languages_page) do
    PageObjects::Page::Organisations::Courses::BackNewModernLanguagesPage.new
  end
  let(:previous_step_page) do
    PageObjects::Page::Organisations::Courses::NewSubjectsPage.new
  end
  let(:new_modern_languages_page) do
    PageObjects::Page::Organisations::Courses::NewModernLanguagesPage.new
  end
  let(:next_step_page) do
    PageObjects::Page::Organisations::Courses::NewAgeRangePage.new
  end

  let(:course) { build(:course, :new, provider: provider) }
  let(:provider) { build(:provider) }
  let(:modern_languages_subject) { build(:subject, :modern_languages) }
  let(:other_subject) { build(:subject, :mathematics) }
  let(:russian) { build(:subject, :russian) }
  let(:modern_languages) { [russian] }
  let(:subjects) { [modern_languages_subject] }
  let(:course) do
    build(:course,
          provider: provider,
          edit_options: {
            subjects: subjects,
            modern_languages: modern_languages,
            age_range_in_years: %w[
                11_to_16
                11_to_18
                14_to_19
              ],
          })
  end
  let(:recruitment_cycle) { build(:recruitment_cycle) }

  before do
    stub_omniauth(provider: provider)
    stub_api_v2_resource(provider)
    stub_api_v2_build_course
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course

    visit signin_path
  end

  context "Page title" do
    scenario "It displays the correct title" do
      visit_modern_languages

      expect(page.title).to start_with("Pick modern languages")
      expect(new_modern_languages_page.title.text).to eq("Pick modern languages")
    end
  end

  context "with modern language selected" do
    let(:build_course_with_selected_value_request) { stub_api_v2_build_course(subjects_ids: [modern_languages_subject.id, russian.id]) }

    scenario "presents the languages" do
      visit_modern_languages
      expect(new_modern_languages_page).to have_no_language_checkbox("Russian")
    end

    scenario "selecting a language" do
      stub_api_v2_build_course(subjects_ids: [modern_languages_subject.id])
      build_course_with_selected_value_request
      visit_modern_languages(course: { subjects_ids: [modern_languages_subject.id] })
      new_modern_languages_page.language_checkbox("Russian").click
      new_modern_languages_page.continue.click
      # When rendering the next step an additional bulid course request will
      # fire off, so it will have been requested twice in total
      expect(build_course_with_selected_value_request).to have_been_requested.twice
    end

    scenario "does not redirect to the previous step" do
      stub_api_v2_build_course(subjects_ids: [other_subject.id])
      build_course_with_selected_value_request
      back_new_modern_languages_page.load(
        provider_code: provider.provider_code,
        recruitment_cycle_year: recruitment_cycle.year,
        course: {},
      )
      expect(new_modern_languages_page).to be_displayed
    end

    context "Error handling" do
      scenario do
        course.errors.add(:modern_languages_subjects, "Invalid")
        stub_api_v2_build_course(subjects_ids: [modern_languages_subject.id])
        visit_modern_languages(course: { subjects_ids: [modern_languages_subject.id] })
        new_modern_languages_page.continue.click
        expect(new_modern_languages_page.error_flash.text).to include("Modern languages subjects Invalid")
      end
    end
  end

  context "without modern language selected" do
    let(:modern_languages) { nil }
    let(:build_course_with_selected_value_request) { stub_api_v2_build_course(subjects_ids: [other_subject.id, russian.id]) }

    scenario "redirects to the next step" do
      stub_api_v2_build_course(subjects_ids: [other_subject.id])
      build_course_with_selected_value_request
      visit_modern_languages(course: { subjects_ids: [other_subject.id] })
      expect(next_step_page).to be_displayed
    end

    scenario "redirects to the previous step" do
      stub_api_v2_build_course(subjects_ids: [other_subject.id])
      build_course_with_selected_value_request
      back_new_modern_languages_page.load(
        provider_code: provider.provider_code,
        recruitment_cycle_year: recruitment_cycle.year,
        course: {},
      )
      expect(previous_step_page).to be_displayed
    end
  end

  def visit_modern_languages(**query_params)
    visit new_provider_recruitment_cycle_courses_modern_languages_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      query_params,
    )
  end
end
