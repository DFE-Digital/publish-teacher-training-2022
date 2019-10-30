require "rails_helper"

feature "Edit course modern languages", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:languages_page) { PageObjects::Page::Organisations::CourseModernLanguages.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:course_request_change_page) { PageObjects::Page::Organisations::CourseRequestChange.new }
  let(:provider) { build(:provider, site: site) }
  let(:site) { build(:site) }
  let(:site_status) { build(:site_status, site: site) }
  let(:edit_options) { { subjects: [], modern_languages: [] } }
  let(:subjects) { [build(:subject, :modern_languages)] }
  let(:course) do
    build(:course,
          provider: provider,
          edit_options: edit_options,
          languages: [],
          subjects: subjects,
          sites: [site],
          site_statuses: [site_status])
  end

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses,accrediting_provider")
    stub_api_v2_resource_collection([course])
    stub_api_v2_resource(course, include: "subjects,site_statuses")
    stub_api_v2_resource(course, include: "sites,accrediting_provider,provider.sites")
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
  end

  context "with a given set of modern languages" do
    let(:french_subject) { build(:subject, :french) }
    let(:japanese_subject) { build(:subject, :japanese) }
    let(:modern_languages) { [japanese_subject, french_subject] }
    let(:edit_options) do
      {
        modern_languages: modern_languages,
        subjects: subjects,
      }
    end

    let(:modern_languages_subject) { build(:subject, :modern_languages) }

    let(:subjects) do
      [
        modern_languages_subject,
      ]
    end

    scenario "can select multiple modern language subjects" do
      languages_page.load_with_course(course)
      edit_languages_stub = stub_api_v2_resource(course, method: :patch)

      languages_page.languages_fields.find('[data-qa="checkbox_language_French"]').click
      languages_page.languages_fields.find('[data-qa="checkbox_language_Japanese"]').click
      languages_page.save.click
      expect(course_details_page).to be_displayed

      expect(edit_languages_stub.with do |request|
        subjects = JSON.parse(request.body)["data"]["relationships"]["subjects"]["data"]
        expect(subjects).to match_array([
          include("id" => modern_languages_subject.id.to_s),
          include("id" => french_subject.id.to_s),
          include("id" => japanese_subject.id.to_s),
        ])
      end).to have_been_made
    end
  end

  context "when a course already has a different language assigned" do
    let(:modern_languages_subject) { build(:subject, :modern_languages) }
    let(:french_subject) { build(:subject, :french) }
    let(:subjects) do
      [
        modern_languages_subject,
        french_subject,
      ]
    end
    let(:modern_languages) { [japanese_subject, russian_subject, french_subject] }
    let(:russian_subject) { build(:subject, :russian) }
    let(:japanese_subject) { build(:subject, :japanese) }
    let(:edit_options) do
      {
        modern_languages: modern_languages,
        subjects: [modern_languages_subject],
      }
    end

    scenario "can select multiple modern language subjects" do
      languages_page.load_with_course(course)
      edit_languages_stub = stub_api_v2_resource(course, method: :patch)

      languages_page.languages_fields.find('[data-qa="checkbox_language_French"]').click
      languages_page.languages_fields.find('[data-qa="checkbox_language_Russian"]').click
      languages_page.languages_fields.find('[data-qa="checkbox_language_Japanese"]').click
      languages_page.save.click
      expect(course_details_page).to be_displayed

      expect(edit_languages_stub.with do |request|
        subjects = JSON.parse(request.body)["data"]["relationships"]["subjects"]["data"]
        expect(subjects).to match_array([
          include("id" => modern_languages_subject.id.to_s),
          include("id" => russian_subject.id.to_s),
          include("id" => japanese_subject.id.to_s),
        ])
      end).to have_been_made
    end

    scenario "checks the current modern language subjects is selected" do
      languages_page.load_with_course(course)

      expect(page).to have_field("course_language_ids_#{french_subject.id}", checked: true)
    end
  end

  context "if no modern languages are available for the course" do
    let(:edit_options) do
      {
        modern_languages: nil,
      }
    end

    scenario "redirects to course details page" do
      languages_page.load_with_course(course)
      expect(course_details_page).to be_displayed
    end
  end
end
