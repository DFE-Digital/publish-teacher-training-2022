require "rails_helper"

feature "Edit course subjects", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:subjects_page) { PageObjects::Page::Organisations::CourseSubjects.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:languages_page) { PageObjects::Page::Organisations::CourseModernLanguages.new }
  let(:course_request_change_page) { PageObjects::Page::Organisations::CourseRequestChange.new }
  let(:provider) { build(:provider, site: site) }
  let(:site) { build(:site) }

  let(:site_status) { build(:site_status, site: site) }
  let(:english_subject) { build(:subject, :english) }
  let(:biology_subject) { build(:subject, :biology) }
  let(:modern_languages_subject) { build(:subject, :modern_languages) }
  let(:russian_subject) { build(:subject, :russian) }
  let(:french_subject) { build(:subject, :french) }
  let(:modern_languages) { [russian_subject, french_subject] }
  let(:subjects) { [] }
  let(:edit_options) do
    {
      subjects: subjects,
      modern_languages: modern_languages,
      modern_languages_subject: modern_languages_subject,
    }
  end
  let(:course_subjects) { [] }
  let(:course) do
    build(
      :course,
      provider: provider,
      edit_options: edit_options,
      subjects: course_subjects,
      sites: [site],
      site_statuses: [site_status],
    )
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

  context "with a given set of available subjects" do
    let(:subjects) { [english_subject, biology_subject] }
    let(:edit_options) do
      {
        subjects: subjects,
        modern_languages: modern_languages,
        modern_languages_subject: modern_languages_subject,
      }
    end

    scenario "can select a master subject based on the level" do
      subjects_page.load_with_course(course)
      edit_subject_stub = stub_api_v2_resource(course, method: :patch)

      subjects_page.master_subject_fields.select(subjects.first.subject_name)
      subjects_page.save_button.click

      subject_uri = URI(current_url)
      expect(subject_uri.path).to eq("/organisations/#{provider.provider_code}/#{current_recruitment_cycle.year}/courses/#{course.course_code}/details")

      expect(edit_subject_stub.with do |request|
        subjects = JSON.parse(request.body)["data"]["relationships"]["subjects"]["data"]
        expect(subjects).to match_array([{ "type" => "subject", "id" => english_subject.id.to_s }])
      end).to have_been_made
    end

    context "with a subordinate subject" do
      let(:course) do
        build(
          :course,
          level: "secondary",
          provider: provider,
          edit_options: edit_options,
          subjects: [],
          sites: [site],
          site_statuses: [site_status],
        )
      end

      scenario "can select a master subject and subordinate subject based on the level" do
        subjects_page.load_with_course(course)
        edit_subject_stub = stub_api_v2_resource(course, method: :patch)

        subjects_page.subjects_fields.select(subjects.first.subject_name)

        subjects_page.subordinate_subject_details.click
        subjects_page.subordinate_subject_fields.select(subjects.second.subject_name)
        subjects_page.save_button.click
        subjects_uri = URI(current_url)
        expect(subjects_uri.path).to eq("/organisations/#{provider.provider_code}/#{current_recruitment_cycle.year}/courses/#{course.course_code}/details")

        expect(edit_subject_stub.with do |request|
          subjects = JSON.parse(request.body)["data"]["relationships"]["subjects"]["data"]
          expect(subjects).to match_array([
            { "type" => "subject", "id" => english_subject.id.to_s },
            { "type" => "subject", "id" => biology_subject.id.to_s },
          ])
        end).to have_been_made
      end

      context "removing a subordinate subject" do
        let(:subjects) { [english_subject, biology_subject] }
        let(:edit_options) do
          {
            subjects: subjects,
            modern_languages: modern_languages,
            modern_languages_subject: modern_languages_subject,
          }
        end
        let(:course) do
          build(
            :course,
            level: "secondary",
            provider: provider,
            edit_options: edit_options,
            subjects: subjects,
            sites: [site],
            site_statuses: [site_status],
          )
        end

        scenario "it updates the course" do
          subjects_page.load_with_course(course)
          edit_subject_stub = stub_api_v2_resource(course, method: :patch)

          subjects_page.master_subject_fields.select(subjects.first.subject_name)
          subjects_page.subordinate_subject_fields.select("")
          subjects_page.save_button.click

          expect(course_details_page).to be_displayed
          expect(edit_subject_stub.with do |request|
            subjects = JSON.parse(request.body)["data"]["relationships"]["subjects"]["data"]
            expect(subjects).to match_array([
              { "type" => "subject", "id" => english_subject.id.to_s },
            ])
          end).to have_been_made
        end
      end

      context "removing all subjects" do
        let(:subjects) { [english_subject, biology_subject] }
        let(:edit_options) do
          {
            subjects: subjects,
            modern_languages: nil,
          }
        end
        let(:course) do
          build(
            :course,
            level: "secondary",
            provider: provider,
            edit_options: edit_options,
            subjects: subjects,
            sites: [site],
            site_statuses: [site_status],
          )
        end

        scenario "it updates the course" do
          subjects_page.load_with_course(course)
          edit_subject_stub = stub_api_v2_resource(course, method: :patch)

          subjects_page.master_subject_fields.select("")
          subjects_page.subordinate_subject_fields.select("")
          subjects_page.save_button.click

          expect(course_details_page).to be_displayed
          expect(edit_subject_stub.with do |request|
            subjects = JSON.parse(request.body)["data"]["relationships"]["subjects"]["data"]
            expect(subjects).to match_array([])
          end).to have_been_made
        end
      end
    end
  end

  context "with modern_languages already set with other languages" do
    let(:french) { build(:subject, :french) }
    let(:japanese) { build(:subject, :japanese) }
    let(:modern_languages) { build(:subject, :modern_languages) }
    let(:subjects) { [french, japanese, modern_languages] }
    let(:edit_options) do
      {
        subjects: [modern_languages],
        modern_languages: [],
      }
    end
    let(:course) do
      build(
        :course,
        provider: provider,
        edit_options: edit_options,
        subjects: subjects,
        sites: [site],
        site_statuses: [site_status],
      )
    end

    scenario "it should automatically select modern_languages" do
      subjects_page.load_with_course(course)
      expect(subjects_page.master_subject_fields.find("option[selected]").text).to eql(modern_languages.subject_name)
    end
  end

  context "with a subject already set" do
    let(:english_subject) { build(:subject, :english) }
    let(:biology_subject) { build(:subject, :biology) }
    let(:subjects) { [english_subject, biology_subject] }
    let(:course_subjects) { [english_subject, biology_subject] }
    let(:course) do
      build(
        :course,
        provider: provider,
        edit_options: edit_options,
        subjects: course_subjects,
        sites: [site],
        site_statuses: [site_status],
      )
    end

    scenario "it should automatically select the current subject" do
      subjects_page.load_with_course(course)
      expect(subjects_page).to have_select("course_master_subject_id", selected: english_subject.subject_name)
    end

    scenario "it should automatically select the current subject" do
      subjects_page.load_with_course(course)
      expect(subjects_page).to have_select("course_subordinate_subject_id", selected: biology_subject.subject_name)
    end

    context "when a modern language subject is selected" do
      let(:subjects) { [modern_languages_subject] }
      let(:course_subjects) { [russian_subject, modern_languages_subject] }

      scenario "selects the correct subjects when a modern language subject is selected" do
        subjects_page.load_with_course(course)

        expect(subjects_page).to have_select("course_master_subject_id", selected: modern_languages_subject.subject_name)
        subjects_page.subordinate_subject_details.click
        expect(subjects_page).to have_select("course_subordinate_subject_id", selected: nil)
      end
    end
  end

  scenario "should show the edit link" do
    course_details_page.load_with_course(course)
    expect(course_details_page).to have_edit_subjects_link
  end
end
