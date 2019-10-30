require "rails_helper"

feature "Edit course subjects", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:subjects_page) { PageObjects::Page::Organisations::CourseSubjects.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:course_request_change_page) { PageObjects::Page::Organisations::CourseRequestChange.new }
  let(:provider) { build(:provider, site: site) }
  let(:site) { build(:site) }
  let(:site_status) { build(:site_status, site: site) }
  let(:edit_options) { { subjects: [] } }
  let(:course) do
    build(:course,
          provider: provider,
          edit_options: edit_options,
          subjects: [],
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

  context "with a given set of subjects" do
    let(:english_subject) { build(:subject, :english) }
    let(:subjects) { [english_subject, build(:subject, :biology)] }
    let(:edit_options) do
      {
        subjects: subjects,
      }
    end

    scenario "can select a master subject based on the level" do
      subjects_page.load_with_course(course)
      edit_subject_stub = stub_api_v2_resource(course, method: :patch)

      subjects_page.subjects_fields.select(subjects.first.subject_name)
      subjects_page.save.click
      expect(course_details_page).to be_displayed

      expect(edit_subject_stub.with do |request|
        subjects = JSON.parse(request.body)["data"]["relationships"]["subjects"]["data"]
        expect(subjects).to match_array([{ "type" => "subject", "id" => english_subject.id.to_s }])
      end).to have_been_made
    end
  end

  context "if subjects have not been changed" do
    let(:modern_languages_subject) { build(:subject, :modern_languages) }
    let(:russian_subject) { build(:subject, :russian) }
    let(:french_subject) { build(:subject, :french) }
    let(:subjects) { [modern_languages_subject, russian_subject, french_subject] }
    let(:course) do
      build(:course,
            provider: provider,
            edit_options: edit_options,
            subjects: subjects,
            sites: [site],
            site_statuses: [site_status])
    end
    let(:edit_options) do
      {
        subjects: [modern_languages_subject],
      }
    end

    scenario "it does not update the course" do
      subjects_page.load_with_course(course)
      edit_subject_stub = stub_api_v2_resource(course, method: :patch)

      subjects_page.subjects_fields.select(subjects.first.subject_name)
      subjects_page.save.click
      expect(course_details_page).to be_displayed
      expect(edit_subject_stub).not_to have_been_made
    end
  end
end
