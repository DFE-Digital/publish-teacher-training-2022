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
  let(:modern_languages_subject) { build(:subject, :modern_languages) }
  let(:french_subject) { build(:subject, :french) }
  let(:russian_subject) { build(:subject, :russian) }
  let(:japanese_subject) { build(:subject, :japanese) }
  let(:modern_languages) { [japanese_subject, russian_subject, french_subject] }
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
    stub_omniauth(provider: provider)
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
        modern_languages_subject: modern_languages_subject,
      }
    end

    let(:subjects) do
      [
        modern_languages_subject,
      ]
    end

    scenario "can select multiple modern language subjects" do
      visit signin_path

      visit(modern_languages_provider_recruitment_cycle_course_path(provider_code: provider.provider_code, recruitment_cycle_year: current_recruitment_cycle.year, code: course.course_code, course: { subjects_ids: [modern_languages_subject.id] }))

      patch_course_stub = set_patch_course_expectation do |subjects|
        expect(subjects).to match_array([
                                          include("id" => modern_languages_subject.id.to_s),
                                          include("id" => french_subject.id.to_s),
                                          include("id" => japanese_subject.id.to_s),
                                        ])
      end

      languages_page.languages_fields.find('[data-qa="checkbox_language_French"]').click
      languages_page.languages_fields.find('[data-qa="checkbox_language_Japanese"]').click
      languages_page.save.click

      expect(course_details_page).to be_displayed
      expect(patch_course_stub).to have_been_made
    end
  end

  context "when a course already has a different language assigned" do
    let(:modern_languages_subject) { build(:subject, :modern_languages) }
    let(:subjects) do
      [
        modern_languages_subject,
        french_subject,
      ]
    end
    let(:edit_options) do
      {
        modern_languages: modern_languages,
        subjects: subjects,
        modern_languages_subject: modern_languages_subject,
      }
    end

    scenario "can select multiple modern language subjects" do
      languages_page.load_with_course(course)
      expect(page).to have_field("course_language_ids_#{french_subject.id}", checked: true)
      patch_course_stub = set_patch_course_expectation do |subjects|
        expect(subjects).to match_array([
                                          include("id" => russian_subject.id.to_s),
                                          include("id" => japanese_subject.id.to_s),
                                        ])
      end

      languages_page.language_checkbox("French").click
      languages_page.language_checkbox("Russian").click
      languages_page.language_checkbox("Japanese").click
      languages_page.save.click

      expect(course_details_page).to be_displayed
      expect(patch_course_stub).to have_been_made
    end
  end

  context "the course has an error" do
    let(:course) do
      build(:course,
            provider: provider,
            edit_options: edit_options,
            languages: [],
            subjects: subjects,
            sites: [site],
            site_statuses: [site_status],
            errors: [
              {
                "source": { "pointer": "/data/attributes/subjects" },
                "title":  "Modern language subjects error",
                "detail": "Modern language subjects error",
              },
            ])
    end

    it "displays the errors" do
      stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}", build(:error), :patch, 422)

      languages_page.load_with_course(course)
      languages_page.save.click
      expect(languages_page).to have_error_flash
    end
  end

  context "when course is not a modern language course" do
    let(:edit_modern_languages_page) do
      PageObjects::Page::Organisations::Courses::EditModernLanguagesPage.new
    end
    let(:subjects) { [build(:subject, :mathematics)] }
    let(:subjects_page) { PageObjects::Page::Organisations::CourseSubjects.new }
    let(:modern_languages) { [japanese_subject, russian_subject, french_subject] }
    let(:edit_options) do
      {
        subjects: [modern_languages_subject],
        modern_languages: modern_languages,
        modern_languages_subject: modern_languages_subject,
      }
    end

    before do
      subjects_page.load_with_course(course)
    end

    context "but is changed to a modern language course" do
      before do
        subjects_page.master_subject_fields.select("Modern Languages")
        subjects_page.save.click
      end

      it "takes user through wizard and saves subjects" do
        expect(CGI.unescape(current_url)).to eql("http://www.example.com/organisations/#{provider.provider_code}/2020/courses/#{course.course_code}/modern-languages?course[subjects_ids][]=#{modern_languages_subject.id}")

        patch_course_stub = set_patch_course_expectation do |subjects|
          expect(subjects).to match_array([
                                            include("id" => modern_languages_subject.id.to_s),
                                            include("id" => russian_subject.id.to_s),
                                            include("id" => japanese_subject.id.to_s),
                                          ])
        end

        languages_page.languages_fields.find('[data-qa="checkbox_language_Russian"]').click
        languages_page.languages_fields.find('[data-qa="checkbox_language_Japanese"]').click
        languages_page.save.click

        expect(patch_course_stub).to have_been_made
      end
    end
  end

private

  def set_patch_course_expectation(&attribute_validator)
    stub_api_v2_resource(course, method: :patch) do |request_body_json|
      subjects = request_body_json["data"]["relationships"]["subjects"]["data"]
      attribute_validator.call(subjects)
    end
  end
end
