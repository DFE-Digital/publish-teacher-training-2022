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

  let(:provider) { build(:provider, sites: [build(:site), build(:site)]) }
  let(:modern_languages_subject) { build(:subject, :modern_languages) }
  let(:other_subject) { build(:subject, :mathematics) }
  let(:japanese) { build(:subject, :japanese) }
  let(:russian) { build(:subject, :russian) }
  let(:modern_languages) { [russian] }
  let(:subjects) { [modern_languages_subject, other_subject] }
  let(:selected_subjects) { [modern_languages_subject] }

  let(:course) do
    build(:course,
          :new,
          subjects: selected_subjects,
          provider: provider,
          edit_options: {
            subjects: subjects,
            modern_languages: modern_languages,
            modern_languages_subject: modern_languages_subject,
            age_range_in_years: %w[
                11_to_16
                11_to_18
                14_to_19
              ],
          },
          accrediting_provider: build(:provider),
          applications_open_from: "2019-10-09",
          gcse_subjects_required: %w[maths science english],
          start_date: "2019-10-09")
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

  context "with modern language subject selected" do
    context "and preselected modern languages" do
      let(:selected_subjects) { [modern_languages_subject, russian] }
      let(:modern_languages) { [russian, japanese] }

      it "replaces the previous selection" do
        stub_api_v2_build_course(subjects_ids: [modern_languages_subject.id, russian.id])
        visit_modern_languages(course: { subjects_ids: [modern_languages_subject.id, russian.id] })
        expect(new_modern_languages_page.language_checkbox("Russian")).to be_checked

        stub_api_v2_build_course(subjects_ids: [modern_languages_subject.id, japanese.id])
        new_modern_languages_page.language_checkbox("Russian").click # to unselect
        new_modern_languages_page.language_checkbox("Japanese").click
        new_modern_languages_page.continue.click

        expect(page).to have_current_path(
          new_provider_recruitment_cycle_courses_age_range_path(
            provider_code: provider.provider_code,
            recruitment_cycle_year: recruitment_cycle.year,
            course: { subjects_ids: [modern_languages_subject.id, japanese.id] },
          ),
        )
      end
    end

    scenario "presents the languages" do
      visit_modern_languages
      expect(new_modern_languages_page).to have_no_language_checkbox("Russian")
    end

    scenario "selecting a language" do
      stub_api_v2_build_course(subjects_ids: [modern_languages_subject.id])
      stub = stub_api_v2_build_course(subjects_ids: [modern_languages_subject.id, russian.id])
      visit_modern_languages(course: { subjects_ids: [modern_languages_subject.id] })
      new_modern_languages_page.language_checkbox("Russian").click
      new_modern_languages_page.continue.click
      # When rendering the next step an additional bulid course request will
      # fire off, so it will have been requested twice in total
      expect(stub).to have_been_requested.twice
    end

    scenario "sends user back to course confirmation" do
      stub_api_v2_build_course(subjects_ids: [modern_languages_subject.id, russian.id])
      visit_modern_languages(course: { subjects_ids: [modern_languages_subject.id, russian.id] }, goto_confirmation: true)

      stub_api_v2_build_course(subjects_ids: [modern_languages_subject.id])
      new_modern_languages_page.continue.click

      expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
    end

    scenario "does not redirect to the previous step" do
      stub_api_v2_build_course(subjects_ids: [other_subject.id])
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
    let(:selected_subjects) { [other_subject, russian] }
    let(:build_course_with_selected_value_request) { stub_api_v2_build_course(subjects_ids: [other_subject.id, russian.id]) }

    scenario "redirects to the next step" do
      stub_api_v2_build_course(subjects_ids: [other_subject.id])
      visit_modern_languages(course: { subjects_ids: [other_subject.id] })
      expect(next_step_page).to be_displayed
    end

    scenario "redirects to the previous step" do
      stub_api_v2_build_course(subjects_ids: [other_subject.id])
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
