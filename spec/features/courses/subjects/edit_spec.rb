require "rails_helper"

xfeature "Edit course subjects", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:subjects_page) { PageObjects::Page::Organisations::CourseSubjects.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:course_request_change_page) { PageObjects::Page::Organisations::CourseRequestChange.new }
  let(:provider) { build(:provider, site: site) }
  let(:subjects) { [] }
  let(:site) { build(:site) }
  let(:site_status) { build(:site_status, site: site) }
  let(:edit_options) { { subjects: subjects } }
  let(:course) do
    build(:course,
          provider: provider,
          edit_options: edit_options,
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

  scenario "can visit the subject edit page" do
    course_details_page.load_with_course(course)
    expect(course_details_page).to be_displayed
    course_details_page.edit_subjects_link.click
    expect(subjects_page).to be_displayed
  end

  context "with a given set of subjects" do
    let(:subjects) { [build(:subject, subject_code: "00")] }
    let(:edit_options) do
      {
        subjects: subjects,
      }
    end

    scenario "can select a subject based on the level" do
      stub_api_v2_resource(course, jsonapi_response: "{\"data\":{\"course_code\":\"X102\",\"type\":\"courses\",\"relationships\":{\"subjects\":{\"data\":[{\"type\":\"subjects\",\"id\":\"2\"}]}},\"attributes\":{}}}")

      subjects_page.load_with_course(course)

      subjects_page.subjects_fields.select(subjects.first.subject_name)
      subjects_page.save.click
      expect(course_details_page).to be_displayed
    end
  end
end
